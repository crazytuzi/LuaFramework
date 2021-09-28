--采集Loading和采集完回城Loading对应的数据管理层
CollectModel =BaseClass(LuaModel)

function CollectModel:__init()
	self:InitData()
	self:InitEvent()
end

function CollectModel:__delete()
	self.collectData = {}
end

function CollectModel:InitData()
	self.collectData = {}
	self.curCollectVo = {} --当前采集vo(只保存最近一个)
end

function CollectModel:InitEvent()

end

function CollectModel:SetCollectVo(collectVo)
	self.curCollectVo  = collectVo or {}
end

function CollectModel:GetCollectVo(collectVo)
	return self.curCollectVo
end


--采集名称，采集总时间
function CollectModel:SetCollectData(title, countDown)
	self.collectData = {}
	self.collectData.title = title or ""
	self.collectData.countDown = countDown or 0
end

function CollectModel:GetCollectData()
	return self.collectData or {}
end

function CollectModel:GetInstance()
	if CollectModel.inst == nil then
		CollectModel.inst = CollectModel.New()
	end
	return CollectModel.inst
end


function CollectModel:CleanData()
	CollectModel.inst = nil
	self.collectData = {}
	self.curCollectVo = {}

end


