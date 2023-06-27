--- Identify parts that are potentially exposed to an explosion using a random vector raycasting
-- @module GetPercentExposed
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RandomVector3Utils = require(ReplicatedStorage.Utilities.RandomVector3Utils)

local GetPercentExposed = {}
GetPercentExposed.RAY_COUNT = 314

--- Searches for percent exposure of all parts given
-- @tparam Vector3 point point to search
-- @tparam number Radius
-- @return A table mapping parts to to percent exposure
function GetPercentExposed.search(point, radius)
	local hits = {}
	local totalHits = 0

	for _=1, GetPercentExposed.RAY_COUNT do
		local ray = Ray.new(point, RandomVector3Utils.getRandomUnitVector() * radius)
		local part = Workspace:FindPartOnRay(ray, nil, true) -- Ignore water
		if part then
			totalHits = totalHits + 1
			hits[part] = (hits[part] or 0) + 1
		end
	end

	if totalHits <= 0 then
		return hits
	end

	for part, count in pairs(hits) do
		hits[part] = count / GetPercentExposed.RAY_COUNT
	end

	return hits
end


return GetPercentExposed