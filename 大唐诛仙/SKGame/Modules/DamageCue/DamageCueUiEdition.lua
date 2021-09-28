require "SKGame/Modules/DamageCue/DamageNum"
--是否暴击
DamageType =
{
	none = 0,
	crit = 1,--暴击
}
--字体Type
FontType = 
{
	MonsterDamageFont = 0, --怪物伤害字体
	PlayerDamageFont = 1, --玩家伤害字体
	AddHpFont = 2, 		--添加生命字体
	CritFont = 3,		--暴击字体
	FightOtherFont = 4,  --战斗其他字体
}

DamageCueUiEdition = BaseClass()
function DamageCueUiEdition:__init()
	self.itemPools = {}
	self.gCom = nil
	self:Init()
	self.old = 0

	self.preCritItem = nil
end

function DamageCueUiEdition:Init()
	if self.gCom == nil then
		self.gCom = GComponent.New()
		self.gCom.name= "gCom"
		layerMgr:GetUILayer():AddChild(self.gCom)
	end
	self:CreatePool()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.BATTLE_PLAYER_HP_CHAGNGE, function ( data )
		self:onHpChange(data)
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.BATTLE_MONSTOR_HP_CHAGNGE,function ( data )
		self:onHpChange(data)
	end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE,function ()
		self:Lock()
	end) --卸载场景时候不允许伤害再进来
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.LOADING_SCENE,function ()
		self:UnLock()
	end) --场景加载完成时开放伤害再进来
end

function DamageCueUiEdition:Lock()
	self.lock = true
end

function DamageCueUiEdition:UnLock()
	self.lock = false 
end

--玩家或者怪物血量改变
function DamageCueUiEdition:onHpChange(data)
	if data == nil then return end
	local obj = data.target
	--if obj == nil or ToLuaIsNull(obj.gameObject) then return end
	local pos = data.pos
	local isCrit = data.isCrit
	local isMiss = data.isMiss
	local num = data.dmg
	local source = data.source
	local fType = 0 --字体
	local player = SceneController:GetInstance():GetScene():GetMainPlayer()
	if obj == player then --自己
		fType = FontType.PlayerDamageFont
	else --其他
		fType = FontType.MonsterDamageFont
	end
	if isCrit then
		fType = FontType.CritFont
	end
	if num > 0 then
		fType = FontType.AddHpFont
	end

	local dmgGroup = nil
	if num > 0 then --回血
		dmgGroup = ""..num
	elseif isMiss then --miss
		dmgGroup = "i"
	elseif isCrit then --暴击
		dmgGroup = "c"..num
	else --伤害
		dmgGroup = ""..num * ( -1 )
	end

	if self.preCritItem and self.preCritItem.step and self.preCritItem.step >= 4 then
	   self.preCritItem:Sleep()
	   self.preCritItem = nil
	end
	fType = self:FilterFontType(obj, fType)
	local item = self:ShowDamage(dmgGroup, pos, fType, obj, source)
	if isCrit then
	   self.preCritItem = item
	end
end

-- 玩家角色自身、队友、召唤兽及队友召唤兽，被攻击扣血时，都用紫色的字体（现在的角色扣血字体）来显示
function DamageCueUiEdition:FilterFontType(obj, fType)
	if not obj or not obj.vo then return fType end
	local player = SceneController:GetInstance():GetScene():GetMainPlayer()
	local zdModel = ZDModel:GetInstance()
	if fType ~= FontType.MonsterDamageFont then return fType end
	if zdModel:IsTeamMate( obj.vo.playerId ) then
		fType = FontType.PlayerDamageFont
	end
	if obj:IsSummonThing() and obj:GetOwnerPlayer() and obj:GetOwnerPlayer().vo then
		if player == obj:GetOwnerPlayer() or zdModel:IsTeamMate(obj:GetOwnerPlayer().vo.playerId) then
			fType = FontType.PlayerDamageFont
		end
	end
	return fType
end

--显示伤害
function DamageCueUiEdition:ShowDamage(dmgGroup, pos, fType, target, source)
	if self.lock then return end 
	if self.old == 0 then self.old = 0.5 else self.old = self.old + 0.5 end
	local ownerPos = pos
	ownerPos.y = ownerPos.y + 2.2 + self.old
	local screenPos = Camera.main:WorldToScreenPoint(ownerPos)
	screenPos.y = UnityEngine.Screen.height - screenPos.y
	local pt = layerMgr:GetUILayer():GlobalToLocal(Vector2(screenPos.x, screenPos.y))
	
	local item = self:GetDamageItem()
	if item == nil then return end
	item:ShowDamage(dmgGroup, fType)
	item:SetTargetSoure(target, source)
	item:StartEffect()
	self:BackflowNum()
	return item
end


function DamageCueUiEdition:BackflowNum()
	local waitTime = 1
	local timer = nil
	timer = Timer.New(function ()
		waitTime = waitTime - 1
		if waitTime == 0 then
			self.old = 0
			timer:Stop()
		end
	end,1,waitTime)
	timer:Start()
end
local b = resMgr:AddUIAB("DamageCue")
--添加飘字缓存池
function DamageCueUiEdition:CreatePool()
	if not b then return end
	for i = 1, 15 do
		local damageItem = DamageNum.New(self.gCom)
		if damageItem ~= nil then 
			damageItem:Sleep()
			table.insert(self.itemPools, damageItem)
		end
	end
end
--从缓存池取
function DamageCueUiEdition:GetDamageItem()
	if #self.itemPools ~= 0 then
		return table.remove(self.itemPools, 1)
	end
	local damageItem = DamageNum.New(self.gCom)
	if damageItem ~= nil then 
		table.insert(self.itemPools, damageItem)
		damageItem:Sleep()
	end
	return damageItem
end



function DamageCueUiEdition:GetInstance()
	if DamageCueUiEdition.inst == nil then
		DamageCueUiEdition.inst = DamageCueUiEdition.New()
	end
	return DamageCueUiEdition.inst
end

function DamageCueUiEdition:__delete()
	for i,v in ipairs(self.itemPools) do
		v:Destroy()
	end
	self.itemPools = {}
	if self.gCom then
		destroyUI( self.gCom )
	end
	self.gCom = nil
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	DamageCueUiEdition.inst = nil
end