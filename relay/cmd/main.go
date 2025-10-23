package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"

	"github.com/comunifi/py-fi/relay/internal/config"
	"github.com/comunifi/py-fi/relay/internal/hooks"
	"github.com/comunifi/py-fi/relay/internal/nostr"
	"github.com/comunifi/py-fi/relay/pkg/common"
	"github.com/fiatjaf/eventstore/postgresql"
	"github.com/fiatjaf/khatru"
)

func main() {
	log.Default().Println("starting relay...")

	////////////////////
	// flags
	// port := flag.Int("port", 3334, "port to listen on")

	env := flag.String("env", ".env", "path to .env file")

	flag.Parse()
	////////////////////

	ctx := context.Background()

	////////////////////

	////////////////////
	// config
	conf, err := config.New(ctx, *env)
	if err != nil {
		log.Fatal(err)
	}
	////////////////////

	////////////////////
	// nostr-postgres
	log.Default().Println("starting internal db service...")

	ndb := postgresql.PostgresBackend{
		DatabaseURL: fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", conf.DBUser, conf.DBPassword, conf.DBHost, conf.DBPort, conf.DBName),
	}

	err = ndb.Init()
	if err != nil {
		log.Fatal(err)
	}
	defer ndb.Close()
	////////////////////

	////////////////////
	// pubkey
	pubkey, err := common.PrivateKeyToPublicKey(conf.RelayPrivateKey)
	if err != nil {
		log.Fatal(err)
	}

	////////////////////

	////////////////////
	// nostr
	relay := khatru.NewRelay()

	relay.Info.Name = conf.RelayInfoName
	relay.Info.PubKey = pubkey
	relay.Info.Description = conf.RelayInfoDescription
	relay.Info.Icon = conf.RelayInfoIcon

	// nostr-service
	n := nostr.NewNostr(conf.RelayPrivateKey, &ndb, relay, conf.RelayUrl)
	////////////////////

	////////////////////
	// main error channel
	quitAck := make(chan error)
	defer close(quitAck)
	////////////////////

	////////////////////
	// nostr
	println("NewRouter there are", len(relay.StoreEvent), "store events")
	r := hooks.NewRouter(n, &ndb)
	relay = r.AddHooks(relay)
	println("AddHooks there are", len(relay.StoreEvent), "store events")

	go func() {
		log.Default().Println("relay running on port: 3334")
		quitAck <- http.ListenAndServe(":3334", relay)
	}()
	////////////////////

	for err := range quitAck {
		if err != nil {
			log.Fatal(err)
		}
	}

	log.Default().Println("relay stopped")
}
