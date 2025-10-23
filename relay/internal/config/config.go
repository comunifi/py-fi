package config

import (
	"context"
	"log"

	"github.com/joho/godotenv"
	"github.com/sethvargo/go-envconfig"
)

type Config struct {
	RelayUrl             string `env:"RELAY_URL,required"`
	DBUser               string `env:"DB_USER,required"`
	DBPassword           string `env:"DB_PASSWORD,required"`
	DBName               string `env:"DB_NAME,required"`
	DBHost               string `env:"DB_HOST,required"`
	DBPort               string `env:"DB_PORT,required"`
	RelayPrivateKey      string `env:"RELAY_PRIVATE_KEY"`
	RelayInfoName        string `env:"RELAY_INFO_NAME"`
	RelayInfoDescription string `env:"RELAY_INFO_DESCRIPTION"`
	RelayInfoIcon        string `env:"RELAY_INFO_ICON"`
}

func New(ctx context.Context, envpath string) (*Config, error) {
	if envpath != "" {
		log.Default().Println("loading env from file: ", envpath)
		err := godotenv.Load(envpath)
		if err != nil {
			return nil, err
		}
	}

	cfg := &Config{}
	err := envconfig.Process(ctx, cfg)
	if err != nil {
		return nil, err
	}

	return cfg, nil
}
