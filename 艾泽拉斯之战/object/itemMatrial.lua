local itemBase = include("itemBase")
local itemMatrial =  class("itemMatrial",itemBase)

function itemMatrial:ctor(tableId)
	 self.super.ctor(self,tableId)
end



return itemMatrial