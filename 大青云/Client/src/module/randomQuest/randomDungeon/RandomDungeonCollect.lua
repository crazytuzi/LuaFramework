--[[
奇遇副本 刷新采集物
2015年7月31日21:25:24
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonCollect = setmetatable( {}, {__index = RandomDungeon} )

RandomDungeonCollect.collectId = nil

function RandomDungeonCollect:GetType()
	return RandomDungeonConsts.Type_Collect
end

function RandomDungeonCollect:GetProgressTxt()
	local progress   = self:GetProgress()
	local totalCount = self:GetTotalCount()
	return string.format( StrConfig['randomQuest010'], progress, totalCount )
end

function RandomDungeonCollect:Init()
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local levelCfg = _G.t_qiyulevel[ level ]
	if not levelCfg then
		Error( string.format( "cannot find config in t_qiyulevel, level : %s", level ) )
	end
	local cfg = self:GetCfg()
	local configKey = "monster_id" .. cfg.param1
	self.collectId = levelCfg[configKey]
	Debug( string.format( "collection id is : %s", self.collectId ) )
end

-- 

function RandomDungeonCollect:EnterAction()
	self:StartAutoPick()
end

function RandomDungeonCollect:StartAutoPick()
	self:StopAutoPick()
	self.pickTimer = TimerManager:RegisterTimer( function()
		if MainPlayerModel:GetItemNum() > 0 then
			DropItemController:DoPickUp()
		end
	end, 501, 0 )
end

function RandomDungeonCollect:StopAutoPick()
	if self.pickTimer then
		TimerManager:UnRegisterTimer( self.pickTimer )
		self.pickTimer = nil
	end
end

function RandomDungeonCollect:DoStep2()
	self:CloseNpcDialog()
	local collection = self:GetCollection()
	if not collection then
		Error( string.format( "cannot find collection" ) )
		return
	end
	local point = collection:GetPos()
	local mapId = CPlayerMap:GetCurMapID()
	local completeFuc = function()
		CollectionController:SendCollect(collection)
	end
	MainPlayerController:DoAutoRun( mapId, _Vector3.new( point.x, point.y, 0 ), completeFuc )
end

function RandomDungeonCollect:GetCollection()
	local collectId = self.collectId
	if not collectId then
		Error( string.foramt( "cannot find collection id" ) )
	end
	return CollectionModel:GetActiveCollectionByCfgId( collectId )
end

function RandomDungeonCollect:GetTotalCount()
	local cfg = self:GetCfg()
	return cfg.param2
end

----------------------- 销毁 -----------------------

function RandomDungeonCollect:Dispose()
	self:StopAutoPick()
	self:StopGuideTimer()
	self:StopQuitTimer()
	if self.subject then
		self.subject:Dispose()
	end
	self.subject = nil
end