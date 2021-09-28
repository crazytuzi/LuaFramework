require "Core.Module.Pattern.BaseModule"
require "Core.Module.ItemMoveEffect.ItemMoveEffectProxy"
local ItemMoveEffectMediator = require "Core.Module.ItemMoveEffect.ItemMoveEffectMediator"
local ItemMoveEffectModule = BaseModule:New();
ItemMoveEffectModule:SetModuleName("ItemMoveEffectModule");
function ItemMoveEffectModule:_Start()
	self:_RegisterMediator(ItemMoveEffectMediator);
	self:_RegisterProxy(ItemMoveEffectProxy);
end

function ItemMoveEffectModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return ItemMoveEffectModule