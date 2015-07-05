local CHARACTER={IsCharacter = function() return true end};
local ITEM={IsItem = function() return true end};
local NPC={IsNPC = function() return true end};
local PROPERTY={IsProperty = function() return true end};
local INV={IsInventory = function() return true end};
local STOR={IsStorage = function() return true end};
local JOB={IsJob = function() return true end};
local GANG={IsGang = function() return true end};

local _findMeta = FindMetaTable;
function FindMetaTable(name)
	if name == "Character" then
		return CHARACTER;
	elseif name == "Item" then
		return ITEM;
	elseif name == "NPC" then
		return NPC;
	elseif name == "Property" then
		return PROPERTY;
	elseif name == "Inventory" then
		return INV;
	elseif name == "Storage" then
		return STOR;
	elseif name == "Job" then
		return JOB;
	elseif name == "Gang" then
		return GANG;
	end
	return _findMeta(name);
end
