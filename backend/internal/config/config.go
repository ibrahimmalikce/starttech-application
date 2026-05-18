package config

import "os"

type Config struct {
	Env       string
	Port      string
	MongoURI  string
	RedisAddr string
}

func Load() *Config {
	return &Config{
		Env:       getEnv("ENV", "development"),
		Port:      getEnv("PORT", "8080"),
		MongoURI:  getEnv("MONGODB_URI", "mongodb://localhost:27017/starttech"),
		RedisAddr: getEnv("REDIS_ADDR", "localhost:6379"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}