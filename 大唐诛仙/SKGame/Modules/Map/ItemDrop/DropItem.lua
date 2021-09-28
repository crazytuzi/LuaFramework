DropItem =BaseClass(Thing)

function DropItem:__init(vo)
	self.type = PuppetVo.Type.DropItem
	self:SetVo(vo)
	self.isInited = true
	self.dropTimes = 1
end

function DropItem:SetVo(vo)
	if vo then
		Thing.SetVo(self, vo)		
	end
end

function DropItem:SetGameObject(go)
	if not go then return end
	Thing.SetGameObject(self, go)
end

function DropItem:Update()
end

function DropItem:GetDropModelName()
	local modelName = nil
	local goodsType = self.vo.goodsType
	local gt = GoodsVo.GoodType
	--从低级到高级颜色为：白，绿，蓝，紫，橙(分表对应对应策划表里面的rare字段的1-5)
	if goodsType == gt.equipment then
		modelName = 5010
	elseif goodsType == gt.item then
		modelName = 5007
	elseif goodsType == gt.gold then
		modelName = 5008
	elseif goodsType == gt.box then
		modelName = 5009
	elseif goodsType == gt.buff then
		local id = self.vo.itemId
		if id then 
			local data = GetCfgData("buff"):Get(id)
			if data then
				modelName = data.resId
			end
		end
	end
	return modelName
end

function DropItem:SetItemShow()
	if self.vo ~= nil then
		local modelName = self:GetDropModelName()
		local loadCallBack = function(o)
			if self.vo ~= nil and self.vo.dropPosition ~= nil and self.vo.itemId ~= nil then
				local pos = self.vo.dropPosition
				local go = GameObject.Instantiate(o)
				local mainPlayerPos = SceneController:GetInstance():GetScene():GetMainPlayerPos()
				if modelName == 5009 then	                             --掉落物品位置默认为玩家位置 宝箱单独使用服务器发送坐标
					mainPlayerPos = pos
				end
				if mainPlayerPos then
					self:SetGameObject(go)
					self:SetPosition(Vector3.New(pos.x, mainPlayerPos.y, pos.z))
					TweenUtils.DoJump(go.transform, Vector3.New(pos.x, mainPlayerPos.y + 2, pos.z) , 0.5, 1, 2)
					self:LoadEffect("30003")
				end
			end
		end
		if modelName ~=nil then
			LoadDrop(modelName, loadCallBack)
		end
	end
end

function DropItem:LoadEffect(res)
	if self.gameObject then
		if self.effectId then EffectMgr.RealseEffect(self.effectId) end
		local callback = function (id)
			local effectGo = EffectMgr.GetEffectById(id)
			if effectGo == nil or not self.isInited then EffectMgr.RealseEffect(self.effectId) return end 
		end
		local destroyCallback = function ()
			EffectMgr.RealseEffect(self.effectId)
		end
		self.effectId = EffectMgr.BindTo(res,self.gameObject,1.6 ,nil,nil,nil,callback,nil,1.3,destroyCallback,nil)
	end
end

function DropItem:GetVo()
	return self.vo
end

function DropItem:__delete()
	self.isInited = false
	GlobalDispatcher:RemoveEventListener(self.handler)
	EffectMgr.RealseEffect(self.effectId)
	self.vo:Destroy()
	self.vo = nil
	self.dropTimes = 0
end