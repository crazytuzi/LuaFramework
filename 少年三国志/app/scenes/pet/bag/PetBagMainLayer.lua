local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local PetBagConst = require("app.const.PetBagConst")
local PetBagPetItem = require("app.scenes.pet.bag.PetBagPetItem")
local PetBagFragmentItem = require("app.scenes.pet.bag.PetBagFragmentItem")
local PetBagMainLayer = class("PetBagMainLayer", UFCCSNormalLayer)

function PetBagMainLayer.create(nTabType, ...)
	return PetBagMainLayer.new("ui_layout/PetBag_MainLayer.json", nil, nTabType, ...)
end

function PetBagMainLayer:ctor(json, param, nTabType, ...)
	self.super.ctor(self, json, param, ...)

	self._nTabType = nTabType or PetBagConst.TabType.PET

	-- 战宠列表视图与数据
	self._tPetListView = nil
	-- 战宠碎片列表视图与数据
	self._tFragmentListView = nil
	-- 图鉴
	self._tBookView = nil

	self._nCurPetId = 0

	--self:_adaterLayer()

	self:_initTabs()
	self:_initWidgets()
end

function PetBagMainLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagChange, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BAG_FRAGMENT_COMPOUND, self._onFragmentCompondSucc, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_CHANGE, self._onChangeFightPet, self)

    if self._shouldReload then
        self._shouldReload = false

        if self._tPetListView ~= nil and self._nCurPetId > 0 then
            local startIndex = self._tPetListView:getShowStart()
            local curDetailIndex = 0
            local tPetIdList = G_Me.bagData.petData:getPetIdListCopy()
            for key, value in pairs(tPetIdList) do 
                if value == self._nCurPetId then 
                    startIndex = key - 2
                    curDetailIndex = key
                end
            end

            self._tPetListView:reloadWithLength(table.nums(tPetIdList), startIndex)

            if curDetailIndex >= 1 then
                self._tPetListView:showDetailWithIndex(curDetailIndex - 1)
            else
                self._tPetListView:hideDetailCell(false)
                self._nCurPetId = 0
            end
        end
    else
        
    end 
end

function PetBagMainLayer:onLayerExit( ... )
	-- body
end

function PetBagMainLayer:_adaterLayer( ... )
	--[[
	self:callAfterFrameCount(2, function ( ... )

		self:adapterWidgetHeight("Panel_Pet", "Panel_181", "", 20, 0)
		self:adapterWidgetHeight("Panel_Fragment", "Panel_181", "", 20, 0)
		self:adapterWidgetHeight("Panel_Content_Book", "Panel_181", "", 20, 0)

		self:adapterWidgetHeight("Panel_Context", "Panel_181", "", 14, 0)

		 self._tabs:checked("CheckBox_" .. self._nTabType)
	end)
]]

	self:adapterWidgetHeight("Panel_Pet", "Panel_181", "", 20, 0)
	self:adapterWidgetHeight("Panel_Fragment", "Panel_181", "", 20, 0)
	self:adapterWidgetHeight("Panel_Content_Book", "Panel_181", "", 20, 0)
	self:adapterWidgetHeight("Panel_Context", "Panel_181", "", 14, 0)

	self._tabs:checked("CheckBox_" .. self._nTabType)
end

function PetBagMainLayer:_initWidgets( ... )
	self:registerBtnClickEvent("Button_return", function()
		uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
	end)

	-- 有没有碎片数量足够合成宠物
	self:showWidgetByName("Image_FragmentTips", G_Me.bagData.petData:couldCompound())

	-- 宠物数量
	CommonFunc._updateLabel(self, "Label_CountValue", {text=G_Me.bagData.petData:getPetCount()})
    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Count'),
        self:getLabelByName('Label_CountValue'),
    }, "C")
    self:getLabelByName('Label_Count'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_CountValue'):setPositionXY(alignFunc(2))

    self:showWidgetByName("Panel_Count", self._nTabType == PetBagConst.TabType.PET)
end

function PetBagMainLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_1", self:getPanelByName("Panel_Pet"), "Label_Pet") 
    self._tabs:add("CheckBox_2", self:getPanelByName("Panel_Fragment"), "Label_Fragment") 
    self._tabs:add("CheckBox_3", self:getPanelByName("Panel_Content_Book"), "Label_Book") 

   -- self._tabs:checked("CheckBox_" .. self._nTabType)
end

function PetBagMainLayer:_checkedCallBack(szCheckBoxName)
	if szCheckBoxName == "CheckBox_1" then
		self._nTabType = PetBagConst.TabType.PET
		if G_Me.bagData.petData:getPetCount() == 0 then
			self:_hasNoPet()
		else
			if self._noPetLayer then
				self._noPetLayer:setVisible(false)
			end
		end
		self:_initPetListView()
		if self._noFragmentLayer then
			self._noFragmentLayer:setVisible(false)
		end
	elseif szCheckBoxName == "CheckBox_2" then
		self._nTabType = PetBagConst.TabType.FRAGMENT
		if table.nums(G_Me.bagData:getPetFragmentList()) == 0 then
			self:_hasNoFragment()
		else
			if self._noFragmentLayer then
				self._noFragmentLayer:setVisible(false)
			end
		end
		self:_initFragmentListView(true)
		if self._noPetLayer then
			self._noPetLayer:setVisible(false)
		end
	elseif szCheckBoxName == "CheckBox_3" then

		if self._noPetLayer then
			self._noPetLayer:setVisible(false)
		end

		if self._noFragmentLayer then
			self._noFragmentLayer:setVisible(false)
		end

		self._nTabType = PetBagConst.TabType.BOOK
		self:_initBookView()

	end
	self:showWidgetByName("Panel_Count", self._nTabType == PetBagConst.TabType.PET)
end

function PetBagMainLayer:_uncheckedCallBack()
	
end

function PetBagMainLayer:_initPetListView()
	if not self._tPetListView then
		local panel = self:getPanelByName("Panel_Pet_List")
		if panel then
			self._tPetListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        self._tPetListView:setCreateCellHandler(function(list, index)
	            return PetBagPetItem.new()
	        end)

	        self._tPetListView:setUpdateCellHandler(function(list, index, cell)
	        	local tPet = G_Me.bagData.petData:getPetByIndex(index + 1)
	        	if tPet then
	        		cell:updateItem(tPet)
	        	end
	        end)

	        local postfix = require("app.scenes.pet.bag.PetBagFosterDetailLayer").create()
		    self._tPetListView:setDetailCell(postfix)
		    self._tPetListView:setDetailEnabled(true)
		    self._tPetListView:setDetailCellHandler(function ( list, detail, cell, index, show )
		        local tPet = G_Me.bagData.petData:getPetByIndex(index + 1)
		        self._nCurPetId = show and tPet["id"] or 0
		    	if show then
		            detail:updateDetailWithPetId(tPet["id"])
		    	end
		    	if cell then
		            cell:onDetailShow(show)
		    	end

		    end)
		    self._tPetListView:setSelectCellHandler(function ( list, knightId, param, cell )
		    	self._tPetListView:showDetailWithIndex(cell:getCellIndex())
		    end)

	        self._tPetListView:initChildWithDataLength(G_Me.bagData.petData:getPetCount(), 0.2)
	        self._tPetListView:setSpaceBorder(0, 40)
		end
	end
end

function PetBagMainLayer:_initFragmentListView(needSort)
	if not self._tFragmentListView or needSort then
		local panel = self:getPanelByName("Panel_Fragment_List")
		if panel then
			self._tFragmentListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
	        self._tFragmentListView:setCreateCellHandler(function(list, index)
	            return PetBagFragmentItem.new()
	        end)

	        self._tFragmentListView:setUpdateCellHandler(function(list, index, cell)
	        	local function contains(nFragmentId)
	        		local tPetList = G_Me.bagData.petData:getPetList()
	        		local isConstains = false
	        		for key, val in pairs(tPetList) do
                        local tPet = val
                        local tPetTmpl = pet_info.get(tPet["base_id"])
                        if tPetTmpl.relife_id == nFragmentId then
                           isConstains = true
                        end
	        		end
	        		return isConstains
	        	end

	        	local function couldHeCheng(tFragment)
	        		local heCheng = false
	        		local tFragmentTmpl = fragment_info.get(tFragment.id)
	        		if tFragment.num >= tFragmentTmpl.max_num then
                        heCheng = true
	        		end
	        		return heCheng
	        	end
	        	
	        	local function realyHeCheng(tFragment)
	        		-- 额，现在又让合成了，代码先注释掉，万一突然又不让合成了方便修改
	        		-- local isConstains = contains(tFragment.id)
	        		local heCheng = couldHeCheng(tFragment)

	        		-- return not isConstains and heCheng
	        		return heCheng
	        	end

			--排序优先级 已上阵  可合成  品质  优化
				local fightPetFragmentId = nil 
				if G_Me.bagData.petData:getFightPet() then 
					fightPetFragmentId = pet_info.get( G_Me.bagData.petData:getFightPet().base_id).relife_id
				end
	        	local function sortFunc(tFragment1, tFragment2)
	        		if type(tFragment1) ~= "table" or type(tFragment2) ~= "table" then
	        			return false
	        		end

	        		local tFragmentTmpl1 = fragment_info.get(tFragment1.id)
	        		local tFragmentTmpl2 = fragment_info.get(tFragment2.id)
	        		-- 已上阵排在最前面
	        		if fightPetFragmentId and tFragment1.id == fightPetFragmentId then return true end
	        		if fightPetFragmentId and tFragment2.id == fightPetFragmentId then return false end
	        		local realyHeCheng1 = realyHeCheng(tFragment1)
	        		local realyHeCheng2 = realyHeCheng(tFragment2)
	        		if realyHeCheng1 ~= realyHeCheng2 then
	        			return (realyHeCheng1 == true)
	        		else
	        			if tFragmentTmpl1.quality ~= tFragmentTmpl2.quality then
	        				return tFragmentTmpl1.quality > tFragmentTmpl2.quality
	        			else
	        				return tFragmentTmpl1.id < tFragmentTmpl2.id
	        			end
	        		end
	        	end

	        	local tFragmentList = G_Me.bagData:getPetFragmentList()
	        	table.sort(tFragmentList, sortFunc)
	        	local tFragment = tFragmentList[index + 1]
	        	if tFragment then
	        		cell:updateData(tFragment)
	        	end

	        	-- 合成
		        cell:setComposeFunc(function()
		            self._clickCell = cell
		            --先判断包裹
		            local CheckFunc = require("app.scenes.common.CheckFunc")
		            if CheckFunc.checkPetFull() then
		                return
		            end
		        	-- 选弹个合成提示框
		        	local maxNum = G_Me.bagData:getMaxPetNumByLevel(G_Me.userData.level)
                    local currNum = G_Me.bagData.petData:getPetCount()
                    require("app.scenes.equipment.MultiComposeLayer").show(tFragment, maxNum, currNum)
		        end)
		        -- 去获取
		        cell:setTogetButtonClickEvent(function()
		            --返回的时候要传入selectType
		            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, tFragment.id, GlobalFunc.sceneToPack("app.scenes.pet.bag.PetBagMainScene", {2, tFragment.id}))
		        end)
		        -- 详细信息
		        cell:setCheckFragmentInfoFunc(function()
		            require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, tFragment.id) 
		        end)

	        end)

	        self._tFragmentListView:initChildWithDataLength(table.nums(G_Me.bagData:getPetFragmentList()), 0.2)
	        self._tFragmentListView:setSpaceBorder(0, 40)
		end
	end
end

function PetBagMainLayer:_initBookView()

	if not self._tBookView then

		self._tBookView = require("app.scenes.pet.bag.PetBagBookLayer").create()
		self:getPanelByName("Panel_Content_Book"):addNode(self._tBookView)
		local size = self:getPanelByName("Panel_Content_Book"):getContentSize()
        self._tBookView:adapterWithSize(CCSizeMake(size.width, size.height))
       	self._tBookView:adapterLayer()

	end

	self._tBookView:reset()
end

function PetBagMainLayer:_onFragmentCompondSucc(data)
	local nFragmentId = data.id
	local nComposeNum = rawget(data, "num") and data.num or 1
	__Log("nFragmentId = " .. nFragmentId)

	if self._tFragmentListView then
		self._tFragmentListView:reloadWithLength(table.nums(G_Me.bagData:getPetFragmentList()))
	end
	if self._tPetListView then
		self._tPetListView:reloadWithLength(G_Me.bagData.petData:getPetCount())
	end

	if table.nums(G_Me.bagData:getPetFragmentList()) == 0 then
		self:_hasNoFragment()
	end

	-- 有没有碎片可以合成的红点
	self:showWidgetByName("Image_FragmentTips", G_Me.bagData.petData:couldCompound())

	require("app.scenes.pet.PetBirthLayer").create(nFragmentId, nComposeNum)

	-- 刷新战宠数量
	CommonFunc._updateLabel(self, "Label_CountValue", {text=G_Me.bagData.petData:getPetCount()})
end

function PetBagMainLayer:_onChangeFightPet(data)
	if self._tPetListView then
		self._tPetListView:hideDetailCell(false)
		self._tPetListView:reloadWithLength(G_Me.bagData.petData:getPetCount())
	end
end


--@desc 收到包裹变化消息,检查下是否有显示
function PetBagMainLayer:_onBagChange(_type,_)
    local BagConst = require("app.const.BagConst")
    if _type == BagConst.CHANGE_TYPE.PET then
    	if self._tPetListView then
    		self._shouldReload = true
    	end
    end
end

function PetBagMainLayer:_hasNoPet()
    local rootWidget = self:getPanelByName("Panel_Context")
    if not self._noPetLayer then
    	self._noPetLayer = require("app.scenes.common.EmptyLayer").createWithPanel(require("app.const.EmptyLayerConst").PET, rootWidget)
    else
    	self._noPetLayer:setVisible(true)
    end
end

function PetBagMainLayer:_hasNoFragment()
    local rootWidget = self:getPanelByName("Panel_Context")
    if not self._noFragmentLayer then
    	self._noFragmentLayer = require("app.scenes.common.EmptyLayer").createWithPanel(require("app.const.EmptyLayerConst").PET_FRAGMENT, rootWidget)
    else
    	self._noFragmentLayer:setVisible(true)
    end
end

return PetBagMainLayer