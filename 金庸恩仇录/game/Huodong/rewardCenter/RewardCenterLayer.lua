local RewardCenterLayer = class("RewardCenterLayer", function()
	return require("utility.ShadeLayer").new()
end)

function RewardCenterLayer:SendRequest()
	RequestHelper.rewardCenter.getInfo({
	callback = function(data)
		self:init(data)
	end
	})
end

-- 背包空间不足
function RewardCenterLayer:lackBag()
	self:addChild(require("utility.LackBagSpaceLayer").new({
	bagObj = self.bagObj,
	callback = function()
		self.isFull = false
	end
	}), 100)
end

function RewardCenterLayer:getRewardMsgBox(cellDatas)
	local title = "恭喜您获得如下奖励："
	local msgBox = require("game.Huodong.RewardMsgBox").new({
	title = title,
	cellDatas = cellDatas
	})
	self:getParent():addChild(msgBox)
	if not game.player.m_isShowRewardCenter then
		PostNotice(NoticeKey.MainMenuScene_RewardCenter)
	end
	self:removeFromParentAndCleanup(true)
end


-- 全部领取
function RewardCenterLayer:collectAllReward()
	if self.isFull then
		self:lackBag()
	else
		RequestHelper.rewardCenter.getReward({
		isGetAll = true,
		objId = "",
		callback = function(data)
			-- dump(data)
			if (string.len(data["0"]) > 0) then
				CCMessageBox(data["0"], "Tip")
			else
				-- game.player.m_isShowRewardCenter = data["2"]
				game.player:updateMainMenu({silver = data["1"].silver, gold = data["1"].gold})
				PostNotice(NoticeKey.MainMenuScene_Update)
				local allCellDatas = {}
				local function checkIsExitItem(iconType, id)
					for _, v in ipairs(allCellDatas) do
						if(v.iconType == iconType and id == v.id) then
						return v
					end
				end
				return nil
			end
			
			for _, v in ipairs(self.cellDatas) do
				for _, cell in ipairs(v.cellData) do
					local item = checkIsExitItem(cell.iconType, cell.id)
					if (item ~= nil) then
						item.num = item.num + cell.num
					else
						table.insert(allCellDatas, cell)
					end
				end
			end
			
			self._rootnode["collect_all_btn"]:setEnabled(false)
			game.player:setRewardcenterNum(0)
			PostNotice(NoticeKey.MainMenuScene_RewardCenter)
			self:getRewardMsgBox(allCellDatas)
		end
	end
	})
end
end


-- 点击领取功能
function RewardCenterLayer:onReward(cell)
	-- 判断背包是否已满
	if self.isFull then
		self:lackBag()
	else
		RequestHelper.rewardCenter.getReward({
		isGetAll = false,
		objId = cell:getObjId(),
		callback = function(data)
			dump(data)			
			if #data["0"] > 0 then
				dump(data["0"])
			else
				-- game.player.m_isShowRewardCenter = data["2"]			
				game.player:updateMainMenu({silver = data["1"].silver, gold = data["1"].gold})
				PostNotice(NoticeKey.MainMenuScene_Update)				
				cell:getReward()				
				game.player:setRewardcenterNum(game.player:getRewardcenterNum() - 1)
				PostNotice(NoticeKey.MainMenuScene_RewardCenter)
				self:getRewardMsgBox(cell:getCellData())
			end
		end
		})
	end
end


function RewardCenterLayer:getItemInfo(rewardType)
	for _, v in ipairs(self.rewardInfoList) do
		if (rewardType == v.type) then
			return v
		end
	end
	print("type类型错误，服务器端传的数据type对应不上！"..tostring(rewardType))
	CCMessageBox("type类型错误，服务器端传的数据type对应不上！", tostring(rewardType))
end


function RewardCenterLayer:init(data)
	if string.len(data["0"]) > 0 then
		CCMessageBox(data["0"], "Tip")
		self:removeSelf()
		return
	end
	
	local data_item_item = require("data.data_item_item")
	--
	local data_lingjiang_lingjiang = require("data.data_lingjiang_lingjiang")
	
	self.isFull = data["2"] or false
	self.rewardListAry = data["1"]
	self.rewardInfoList = data_lingjiang_lingjiang
	self.cellDatas = {}
	
	self._rootnode["reward_count_label"]:setString("当前奖励数：" .. #self.rewardListAry)
	
	local function createCellDats()
		for _, v in ipairs(self.rewardListAry) do
			local itemData = {}
			for _, itemV in ipairs(v.item) do
				local item = data_item_item[itemV.id]
				local iconType = ResMgr.getResType(itemV.type)
				if  iconType == ResMgr.HERO then
					item = ResMgr.getCardData(itemV.id)
				end
				
				table.insert(itemData, {
				id = itemV.id,
				type = itemV.type,
				name = item.name,
				describe = item.describe,
				iconType = iconType,
				num = itemV.num or 0
				})
			end
			
			table.insert(self.cellDatas, {
			objId = v._id,
			cellData = itemData
			})
		end
	end
	
	createCellDats()
	
	local listView = self._rootnode["listView"]
	local listViewSize = listView:getContentSize()
	
	local boardWidth = listViewSize.width
	local boardHeight = listViewSize.height * 0.97
	
	local function getRewardInfo(index)
		local reward = self.rewardListAry[index]
		local itemInfo = self:getItemInfo(reward.type)
		local title = itemInfo.name
		local otherData = reward.otherData
		local describe = itemInfo.describe
		if otherData ~= nil and type(otherData) == "table" then
			if (#otherData == 2) then
				describe = string.format(describe, otherData[1], otherData[2])
			elseif (#otherData == 1) then
				describe = string.format(describe, otherData[1])
			end
		end
		return reward, title, describe
	end
	
	-- 创建
	local function createFunc(index)
		local reward, title, describe = getRewardInfo(index + 1)
		local itemCell = require("game.Huodong.rewardCenter.RewardCenterCell").new()
		return itemCell:create({
		id = index,
		viewSize = cc.size(boardWidth, boardHeight),
		objId = reward._id,
		title = title,
		describe = describe,
		time = reward.time,
		cellData = self.cellDatas[index + 1].cellData,
		rewardListener = handler(self, RewardCenterLayer.onReward)
		})
	end
	
	-- 刷新
	local function refreshFunc(cell, index)
		local reward, title, describe = getRewardInfo(index + 1)
		cell:refresh({
		id = index,
		objId = reward._id,
		title = title,
		describe = describe,
		time = reward.time,
		cellData = self.cellDatas[index + 1].cellData
		})
	end
	
	local cellContentSize = require("game.Huodong.rewardCenter.RewardCenterCell").new():getContentSize()
	
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.rewardListAry,
	cellSize = cellContentSize
	})
	
	self.ListTable:setPosition(0, listViewSize.height * 0.015)
	listView:addChild(self.ListTable)
end

function RewardCenterLayer:ctor(data)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_center_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode["titleLabel"]:setString("领奖中心")
	self._rootnode["reward_msg_lable"]:setString("奖励14天内不领取会自动消失")
	self._rootnode["reward_count_label"]:setString("当前奖励数：0")
	
	-- 关闭
	self._rootnode["tag_close"]:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			self:removeSelf()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	-- 全部领取
	local collectAllBtn = self._rootnode["collect_all_btn"]
	collectAllBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		collectAllBtn:setEnabled(false)
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			self:collectAllReward()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	self:init(data)
	
end

function RewardCenterLayer:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return RewardCenterLayer