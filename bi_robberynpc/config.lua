Config = {}

-- logs discord 
Config.DiscordWebhook = 'VOTRE WEBHOOK DISCORD '

Config.RichZones = {
    "Rockford Hills", "Vinewood", "Richman", "Del Perro"
}

Config.PoorZones = {
    "Davis", "Strawberry", "Chamberlain Hills", "Rancho"
}

Config.MiddleClassZones = {
    "La Mesa", "Murrieta Heights", "Pillbox Hill", "Mission Row"
}

-- zone 
Config.RichZoneMoney = {min = 500, max = 1000}
Config.PoorZoneMoney = {min = 20, max = 100}
Config.MiddleClassZoneMoney = {min = 100, max = 300}

-- reputation
Config.InitialReputation = 0
Config.BadReputationThreshold = -5
Config.GoodReputationThreshold = 5

-- Chance de réussir (sur 100)
Config.ChanceToStealMoney = 45
-- Chance d'objet (sur 100)
Config.ChanceToReceiveItem = 10


-- Liste items
Config.RobberyItems = {
    {name = "water", quantity = 1},
    {name = "bread", quantity = 1},
}
