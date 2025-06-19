local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local currentJobId = game.JobId

local function findLowPopServer()
    local cursor = ""
    local lowest = nil
    local lowestPlayerCount = math.huge
    for i = 1, 10 do -- Try up to 10 pages
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= currentJobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
                    if server.playing < lowestPlayerCount then
                        lowest = server
                        lowestPlayerCount = server.playing
                    end
                end
            end
            if result.nextPageCursor then
                cursor = result.nextPageCursor
            else
                break
            end
        else
            warn("Failed to fetch server list. Hit rate limit or error. Waiting before retrying...")
            task.wait(3) -- Wait longer after an error
        end
        task.wait(1) -- Wait after every page to avoid rate limit
    end
    return lowest
end

local targetServer = findLowPopServer()
if targetServer then
    print("Teleporting to server:", targetServer.id, "Players:", targetServer.playing)
    TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, Players.LocalPlayer)
else
    warn("No less-populated server found. Rejoining current server.")
    TeleportService:Teleport(placeId, Players.LocalPlayer)
end
