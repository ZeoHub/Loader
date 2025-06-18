local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local currentJobId = game.JobId

local MAX_PLAYERS_IN_TARGET = 1 -- Only allow servers with 1 or fewer players
local ERROR_WAIT = 2

-- Function to find a low-pop server
local function findFastLowPopServer()
    local bestServer = nil
    local bestCount = math.huge
    local cursor = ""
    for i = 1, 10 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= currentJobId and server.playing and server.maxPlayers and server.playing <= MAX_PLAYERS_IN_TARGET then
                    if server.playing < bestCount then
                        bestServer = server
                        bestCount = server.playing
                        return bestServer -- Found lowest, return immediately
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
            task.wait(ERROR_WAIT)
        end
    end
    return bestServer
end

-- Try to get queue_on_teleport function
local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local scriptToQueue = [[loadstring(game:HttpGet("https://get.nathub.xyz/loader"))()]]

local function safeTeleport(placeId, jobId)
    if q then
        q(scriptToQueue)
    end
    local connection
    connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        warn("Teleport failed: " .. tostring(errorMessage))
        if teleportResult == Enum.TeleportResult.GameFull then
            warn("Target server is full, retrying another server...")
            local newServer = findFastLowPopServer()
            if newServer then
                TeleportService:TeleportToPlaceInstance(placeId, newServer.id, Players.LocalPlayer)
            else
                warn("No available servers found for retry.")
            end
        else
            warn("Teleport failed for another reason: " .. tostring(teleportResult))
        end
        if connection then connection:Disconnect() end
    end)
    TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
end

-- Main logic
local function checkAndTeleportIfFull()
    local currentPlayers = #Players:GetPlayers()
    if currentPlayers > MAX_PLAYERS_IN_TARGET then
        warn("Server is full (" .. currentPlayers .. " players). Teleporting to a low-pop server and will auto-load script after join...")
        local targetServer = findFastLowPopServer()
        if targetServer then
            safeTeleport(placeId, targetServer.id)
        else
            warn("No suitable public server found. Please try again later.")
        end
    else
        warn("You are in a server with " .. currentPlayers .. " player(s). Running loader.")
        loadstring(game:HttpGet("https://get.nathub.xyz/loader"))()
    end
end

checkAndTeleportIfFull()
