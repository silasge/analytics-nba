import tomllib

with open("configs.toml", "rb") as cfg:
    configs = tomllib.load(cfg)