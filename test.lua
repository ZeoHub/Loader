-- Rejoin to a public server (not the current one)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local PlaceId = game.PlaceId
local LocalPlayer = Players.LocalPlayer

-- Try to find a different public server
local function getRandomServer()
    local HttpService = game:GetService("HttpService")
    local servers = {}
    local req = syn and syn.request or http and http.request or http_request or request
    if not req then
        warn("Your executor does not support HTTP requests.")
        return nil
    end
    local cursor = ""
    while true do
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=2&limit=100%s", PlaceId, cursor ~= "" and "&cursor="..cursor or "")
        local response = req({Url = url, Method = "GET"})
        if response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            if data.nextPageCursor then
                cursor = data.nextPageCursor
            else
                break
            end
        else
            break
        end
    end
    if #servers > 0 then
        return servers[math.random(1, #servers)]
    else
        return nil
    end
end

local serverId = getRandomServer()
if serverId then
    TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
    print("Rejoining a different public server!")
else
    print("No available public servers found. Rejoining same server instead.")
    TeleportService:Teleport(PlaceId)
end
