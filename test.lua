local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local placeId = 126884695634066 -- Replace with your game's actual PlaceId

-- List your private server IDs here, in order of preference (NOT URLs!)
local privateServerIds = {
    "b35901cb37e539488443859bc139311b",
    "f921960f9ea9ef49bdd76d922625dcbe",
    -- Add more as needed
}

local teleportEvent = ReplicatedStorage:WaitForChild("TeleportToPrivateServerEvent")

teleportEvent.OnServerEvent:Connect(function(player)
    local triedServers = {}
    for _, privateServerId in ipairs(privateServerIds) do
        if triedServers[privateServerId] then continue end
        triedServers[privateServerId] = true

        local failed = false
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(failedPlayer, teleportResult, errorMessage)
            if failedPlayer == player then
                warn("Teleport failed: " .. tostring(errorMessage))
                if teleportResult == Enum.TeleportResult.GameFull then
                    warn("Private server is full, trying next in list...")
                    failed = true
                else
                    warn("Teleport failed for another reason: " .. tostring(teleportResult))
                end
                if connection then connection:Disconnect() end
            end
        end)

        TeleportService:TeleportToPrivateServer(placeId, privateServerId, {player})

        -- Wait for a short time to see if there is a failure
        local timeout = 10
        while timeout > 0 and not failed do
            task.wait(1)
            timeout = timeout - 1
        end

        if not failed then
            -- Either teleport is in progress or succeeded, stop trying
            if connection then connection:Disconnect() end
            break
        end
    end
end)
