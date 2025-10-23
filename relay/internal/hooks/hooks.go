package hooks

import (
	"github.com/comunifi/py-fi/relay/internal/nostr"
	"github.com/fiatjaf/eventstore/postgresql"
	"github.com/fiatjaf/khatru"
)

type Router struct {
	n   *nostr.Nostr
	ndb *postgresql.PostgresBackend
}

func NewRouter(n *nostr.Nostr, ndb *postgresql.PostgresBackend) *Router {
	return &Router{n: n, ndb: ndb}
}

func (r *Router) AddHooks(relay *khatru.Relay) *khatru.Relay {
	// instantiate handlers

	// saving events
	relay.StoreEvent = append(relay.StoreEvent, r.ndb.SaveEvent)

	// querying events
	relay.QueryEvents = append(relay.QueryEvents, r.ndb.QueryEvents)

	// counting events
	relay.CountEvents = append(relay.CountEvents, r.ndb.CountEvents)

	// deleting events
	relay.DeleteEvent = append(relay.DeleteEvent, r.ndb.DeleteEvent)

	// replacing events
	relay.ReplaceEvent = append(relay.ReplaceEvent, r.ndb.ReplaceEvent)

	return relay
}
