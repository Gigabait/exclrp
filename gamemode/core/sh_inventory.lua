--sh_inventory

-- Metatable. See util/sh_overrides.lua
local INV = FindMetaTable("Inventory")

-- Decoding
function ERP.DecodeInventory(str)
	local tab=ES.Deserialize(str or "");

	local inv = ERP.Inventory();
	if tab.w then
		inv:SetWidth(tab.w);
	end

	if tab.h then
		inv:SetHeight(tab.h)
	end

	if tab.grid then
		inv.grid = tab.grid;
	end

	return inv
end

-- Encoding
function ERP.EncodeInventory(tbl)
	return ES.Serialize(tbl or {})
end

-- Inventory object
function ERP.Inventory()
	local i={}
	setmetatable(i,INV)
	INV.__index=INV;

	i.grid={}
	i.w=1;
	i.h=1;

	return i;
end

-- Some utility functions
AccessorFunc(INV,"w","Width",FORCE_NUMBER)
AccessorFunc(INV,"h","Height",FORCE_NUMBER)
function INV:GetSize()
	return self.w,self.h;
end
function INV:HasItem(item)
	return table.HasValue(self:GetItems(),item:GetName());
end
function INV:HasItemAt(item,x,y)
	return tobool(ERP.ValidItem(item) and self.grid[x] and self.grid[x][y] and self.grid[x][y] == item:GetName())
end

-- Get the grid with item IDs at [x][y]. No fillers.
function INV:GetGrid()
	return self.grid;
end

-- Get all items as a numeral array
function INV:GetItems()
	local items={};
	for x,_t in pairs(self.grid) do
		for y,item in pairs(_t) do
			if ES.Items[item] then
				table.insert(items,ES.Items[item]);
			end
		end
	end
	return items;
end

-- Gets a table that tells us whether there is space at a certain point in the inventory.
-- true/1 means filled, false/0 means not filled.
-- TODO: Needs serious optimization
function INV:GetSpace()
	local space={};
	for x,_t in pairs(self.grid) do
		for y,item in pairs(_t) do
			item=ERP.Items[item];
			if item then
				for _x=x,x+item:GetInventoryWidth()-1 do
					for _y=y,y+item:GetInventoryHeight()-1 do
						if not space[_x] then space[_x] = {} end
						space[_x][_y] = true;
					end
				end
			end
		end
	end
	return space;
end

-- Find a spot for the item
-- TODO: Needs serious optimization
function INV:FitItem(item)
	if not ERP.ValidItem(item) then return 0,0 end

	local w,h = self:GetSize();
	local grid = self:GetSpace();

	for x=1,w do
		for y=1,h do
			if not grid[x] or not grid[x][y] then
				local nope=false;
				for _x=x,x+item:GetInventoryWidth()-1 do
					for _y=y,y+item:GetInventoryHeight()-1 do
						if _x > w or y > h or grid[x] and grid[x][y] then
							local nope=true;
							break;
						end
					end
				end
				if not nope then
					return x,y;
				end
			end
		end
	end

	return 0,0
end
function INV:FitItemAt(item,x,y)
	if not ERP.ValidItem(item) then return 0,0 end

	local w,h = self:GetSize();
	local grid = self:GetSpace()

	if x > w or y > h or x < 1 or y < 1 then return 0,0 end

	local nope=false;
	for _x=x,x+item:GetInventoryWidth()-1 do
		for _y=y,y+item:GetInventoryHeight()-1 do
			if _x > w or y > h or grid[x] and grid[x][y] then
				return 0,0
			end
		end
	end

	return x,y
end
