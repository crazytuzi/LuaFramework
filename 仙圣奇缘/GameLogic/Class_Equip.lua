--------------------------------------------------------------------------------------
-- 文件名:	Class_Equip.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	装备
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CEquip类
Class_Equip = class("Class_Equip",  function() return Class_GameObj:new() end)
Class_Equip.__index = Class_Equip

--初始化数据
function Class_Equip:initEquipData(tbEquip)
	if(not tbEquip)then
		return
	end
	
	self.nServerID = tbEquip.equip_id					--装备ID
	self.nCsvID = tbEquip.equip_configid		--装备配置ID
	self.nStarLevel = tbEquip.equip_star_level	 	--装备等级 --星等
	self.nOwnerID = tbEquip.owner_card_id or 0	--所属伙伴ID，没有就为0
	self.nLevel = tbEquip.strengthen_lv	or 0	--强化等级
	--[[
		装备升级 --UI表现为星级
	]]
	self.nRefineLevel = tbEquip.equip_refine_lv or 0
	self.tbProps = {}								--随机属性
	local tbRandomProp = tbEquip.random_prop

	if(tbRandomProp)then
		for i =1, #tbRandomProp do
			local tbRandomPropItem = tbRandomProp[i]
			self.tbProps[i] = {
				Prop_Type = tbRandomPropItem.prop_type,
				Prop_Value = tbRandomPropItem.prop_value
			}
		end
	end
	self.tbCsvBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	--保存装备数据，没有取星级
	self.tbEquipCsv = g_DataMgr:getCsvConfigByOneKey("Equip",self.nCsvID)
	
	return self.nServerID
end

function Class_Equip:initEquipDropData(tbEquip)
	if(not tbEquip)then
		return
	end
	
	self.nServerID = tbEquip.drop_item_id						--装备ID
	self.nCsvID = tbEquip.drop_item_config_id			--装备配置ID
	self.nStarLevel = tbEquip.drop_item_star_lv	 			--装备等级--星等
	--所属伙伴ID，没有就为0
	self.nOwnerID = tbEquip.drop_owner_id or 0									
	self.nLevel = tbEquip.drop_item_lv				    --强化等级
	--[[
		装备升级 --UI表现为星级
	]]
	self.nRefineLevel = 0						
	
	self.tbProps = {}									--随机属性
	local tbRandomProp = tbEquip.drop_random_prop
	for i =1, #tbRandomProp do
		local tbRandomPropItem = tbRandomProp[i]
		self.tbProps[i] = {
			Prop_Type = tbRandomPropItem.prop_type,
			Prop_Value = tbRandomPropItem.prop_value
		}
	end
	self.tbCsvBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	
	self.tbEquipCsv = g_DataMgr:getCsvConfigByOneKey("Equip",self.nCsvID)
	return self.nServerID, self.nOwnerID
end

--获取物品基本数据表
function Class_Equip:getCsvBase()
	return self.tbCsvBase
end

function Class_Equip:setCsvBase(csvBase)
	self.tbCsvBase = csvBase
end

--获取物品基本数据表 星级
function Class_Equip:getCsvEquip(starLevel)
	return self.tbEquipCsv[starLevel]
end

--获取装备星级
function Class_Equip:getStarLevel()
	return self.nStarLevel
end

function Class_Equip:getColorType()
	return self:getCsvBase().ColorType
end

--获取装备升级等级 --UI表现为星级
function Class_Equip:getRefineLev()
	return self.nRefineLevel
end




--获取下一级合成等级与数据
function Class_Equip:getNextEquipStarLevel()
	local CSV_Equip = self:getCsvBase()
	--下一星级
	local nextStarLevel = self.nStarLevel + 1
	--下一星级数据 装备品质
	local csvEquipInfo = self:getCsvEquip(nextStarLevel)
	if csvEquipInfo and  csvEquipInfo.ID > 0 then
		--返回下一星级 ,下一星级数据
		return nextStarLevel, csvEquipInfo
	end
	--最大星级，是否已经满星 装备品质
	local maxEquipMaxSatr, flagMaxEuqipSatr = self:equipMaxStar()
	if flagMaxEuqipSatr then
		--满级了 返回 最大星级,当前数据
		return maxEquipMaxSatr, CSV_Equip
	end
	--出错了 返回 星级为0,数据为当前数据 初始为1级数据
	return 0, CSV_Equip
end

function Class_Equip:getNextRefineLevel()
	local cvs_refineCost = g_EquipRefineStarUpData:getCSVEquipRefineCost()
	local maxRefineLevel, flagMaxRefineLevel = self:refineMaxLevel()
	local refineLevel = self.nRefineLevel + 1
	local cvsRefineCostInfo = cvs_refineCost[refineLevel]
	if cvsRefineCostInfo then 
		return refineLevel, cvsRefineCostInfo
	end
	if flagMaxRefineLevel then 
		return maxRefineLevel, cvs_refineCost[self.nRefineLevel]
	end
	return 0, cvs_refineCost[self.nRefineLevel]
end

--获取装备强化等级
function Class_Equip:getStrengthenLev()
	return self.nLevel
end

--获取当前装备强化等级上限
function Class_Equip:getEquipStrengthenCostCsvMaxLevelel()
	local nMaxStrengthenLev = g_DataMgr:getEquipStrengthenCostCsvMaxLevel()
	return math.min(g_Hero:getMasterCardLevel(), nMaxStrengthenLev)
end

function Class_Equip:getStrengthenCost()
	local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv(self:getStrengthenLev())
	return CSV_EquipStrengthenCost.StrengthenCost
end

--判断装备是否已达到强化上限
function Class_Equip:checkIsStrengthenLevelFull()
	if self:getStrengthenLev() >= self:getEquipStrengthenCostCsvMaxLevelel() then return true end
	return false
end

--设置装备星级
-- function Class_Equip:setStarLevel(nStarLevel)
	-- self.nStarLevel = nStarLevel
	-- self.tbCsvBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	-- self:updateOwnerCardMainProps()
-- end

--[[
	设置装备升级 --升星
	--装备精炼修改为装备升级 UI表现为星级
]]
function Class_Equip:setRefineLev(nRefineLevel)
	self.nRefineLevel = nRefineLevel
    self:updateOwnerCardMainProps()
end

--[[
	装备精炼等级 --UI表现为星级
	@return 装备精炼最大等级 true 数据正确 装备精炼最大等级 
]]
function Class_Equip:refineMaxLevel()
	local equipRefineCost = g_EquipRefineStarUpData:getCSVEquipRefineCost()
	-- g_DataMgr:getCsvConfig("EquipRefineCost")
	return #equipRefineCost,self.nRefineLevel == #equipRefineCost
end	
	
--[[
	装备星级 --品质等级
	这样的取最大星级 在表结构改变的时候需要修改
	@return 0 装备ID 取表数据为空 false 数据出错
	@return 装备最大星级 true 数据正确 装备最大星级
]]
function Class_Equip:equipMaxStar()
	if not self.tbEquipCsv then 
		return 0,false
	end
	return #self.tbEquipCsv,self.nStarLevel == #self.tbEquipCsv
end

--检查当前装备是否已经合成最高档次的最大等级
function Class_Equip:checkMaxRefineAndMaxStar()
	local _,maxStar = self:equipMaxStar()
	return maxStar
	-- if self:checkMaxRefine() then
		-- local CSV_Equip = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel + 1)
		-- if CSV_Equip.ID == 0 then --获取不到配置说明到达最高星级了
			-- return true
		-- else
			-- return false
		-- end
	-- else
		-- return false
	-- end
end

--设置装备星级、合成等级
--[[
	又以前装备精炼改为合成装备
	合成的效果提示装备品质
	@param nStarLevel 装备星级 表示装备品质
]]
function Class_Equip:setStarAndRefineLev(nStarLevel)
	self.nStarLevel = nStarLevel
	-- self.nRefineLevel = nRefineLevel
	self.tbCsvBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
    self:updateOwnerCardMainProps()
end

--设置装备强化等级
function Class_Equip:setStrengthenLev(nLevel)
	self.nLevel = nLevel
    self:updateOwnerCardMainProps()
end

function Class_Equip:updateOwnerCardMainProps()
    if self.nOwnerID and self.nOwnerID > 0 then
        local GameObj_CardOwner = g_Hero:getCardObjByServID(self.nOwnerID)
        if GameObj_CardOwner then
			GameObj_CardOwner:reCalculateEquipMainProps(self)
        end
    end
end

function Class_Equip:updateOwnerCardAddProps(nRandomPropTypeNew, nRandomPropValueNew, nRandomPropTypeOld, nRandomPropValueOld)
    if self.nOwnerID and self.nOwnerID > 0 then
        local tbOwnerCard = g_Hero:getCardObjByServID(self.nOwnerID)
        if tbOwnerCard then
			tbOwnerCard:reCalculateCardEquipAddProps(nRandomPropTypeNew, nRandomPropValueNew, nRandomPropTypeOld, nRandomPropValueOld)
        end
    end
end

--[[
获得装备的出售价格
出售价格 = 装备当前基础售价BasePrice
	+ 装备当前精炼等级对应的精炼消耗NeedMoney
	+ 装备当前强化等级对应的累计消耗 StrengthenCostSum
	* 装备强化消耗系数 StrengthenFactor / 10000
]]

function Class_Equip:getSellPrice()
	local CSV_Equip = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	-- local CVS_equipRefineMaterial =  g_DataMgr:getEquipHeChengMaterialCsv(CSV_Equip.HeChengMaterialGroupID)
	local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv(self.nLevel)
	
	local EquipRefineCost = g_DataMgr:getCsvConfigByOneKey("EquipRefineCost",self:getRefineLev())
	
	local NeedMoneySum = 0
	if CSV_Equip.Type == Enum_EuipMainType.Weapon then
		NeedMoneySum = EquipRefineCost.NeedMoneySum_Weapon
	elseif CSV_Equip.Type == Enum_EuipMainType.Ring then
		NeedMoneySum = EquipRefineCost.NeedMoneySum_Ring
	else
		NeedMoneySum = EquipRefineCost.NeedMoneySum
	end
	
	--装备当前基础售价
	local basePrice = CSV_Equip.BasePrice
	-- 装备强化消耗系数
	local strengthenFactor = CSV_Equip.StrengthenFactor
	-- 装备当前强化等级对应的累计消耗
	local strengthenCostSum = CSV_EquipStrengthenCost.StrengthenCostSum
	local money = basePrice + NeedMoneySum + (strengthenCostSum * strengthenFactor / g_BasePercent) * 0.4
	return math.ceil(money)
end

--获取装备随机属性
function Class_Equip:getEquipTbProp()
	return self.tbProps
end

--设置装备随机属性
function Class_Equip:setEquipTbProp(nRandomIdx, tbRandomProp)
	if nRandomIdx and tbRandomProp then
		local nRandomPropTypeOld = self.tbProps[nRandomIdx].Prop_Type
		local nRandomPropValueOld = self.tbProps[nRandomIdx].Prop_Value
		self.tbProps[nRandomIdx].Prop_Type = tbRandomProp.prop_type
		self.tbProps[nRandomIdx].Prop_Value = tbRandomProp.prop_value
        self:updateOwnerCardAddProps(tbRandomProp.prop_type, tbRandomProp.prop_value, nRandomPropTypeOld, nRandomPropValueOld)
	end
end

--设置装备所装备的伙伴ID
function Class_Equip:setOwnerID(nOwnerID)
	self.nOwnerID = nOwnerID
end

--[[类型1：拳爪 类型2：刀剑 类型3：弓弩 类型4：法杖 类型5：枪戟 类型6：戒指 类型7：奇物 类型8：法袍 类型9：鞋子]]
--武器部位，则可装备子类型为拳爪、刀剑、弓弩、法杖、枪戟的装备
--1-5 武器 戒指 奇物 法袍 鞋子
function Class_Equip:getTbType()
	local tbBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	local nType = tbBase.Type
	local tbCurEquip = nil
	if(nType == 1)then --装备
		nType = 1
	else
		--类型6：戒指 类型7：奇物 类型8：法袍 类型9：鞋子
		nType = tbBase.SubType - 4	
	end
	
	return nType
end

function Class_Equip:getTbSubTypeName()
	local tbBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	local nType = tbBase.Type
	
	return getSubTypeNameByType(nType)
end

function Class_Equip:playEquipSound()
	local tbBase = g_DataMgr:getEquipCsv(self.nCsvID, self.nStarLevel)
	local nType = tbBase.SubType
	
	if nType == 1 then
		g_playSoundEffect("Sound/Equip_Claw.mp3")
	elseif nType == 2 then
		g_playSoundEffect("Sound/Equip_Sword.mp3")
	elseif nType == 3 then
		g_playSoundEffect("Sound/Equip_Bow.mp3")
	elseif nType == 4 then
		g_playSoundEffect("Sound/Equip_Staff.mp3")
	elseif nType == 5 then
		g_playSoundEffect("Sound/Equip_Pike.mp3")
	elseif nType == 6 then
		g_playSoundEffect("Sound/Equip_Ring.mp3")
	elseif nType == 7 then
		g_playSoundEffect("Sound/Equip_Necklace.mp3")
	elseif nType == 8 then
		g_playSoundEffect("Sound/Equip_Clothes.mp3")
	elseif nType == 9 then
		g_playSoundEffect("Sound/Equip_Shoes.mp3")
	end
end

--获取装备拥有者的名字
function Class_Equip:getOwnerName(Label_Owner)
	if(not self.nOwnerID or self.nOwnerID <= 0)then
		g_SetTextPlainYellow(Label_Owner)
		return _T("未装备")
	end
	
	local tbCard = g_Hero:getCardObjByServID(self.nOwnerID)
	if(not tbCard)then
		self.nOwnerID = 0
		g_SetTextPlainYellow(Label_Owner)
		return _T("未装备")
	end
	
	g_SetPlainOrange(Label_Owner)
	return _T("装备于")..tbCard:getName()
end

function Class_Equip:getOwnerID()
	if(not self.nOwnerID or self.nOwnerID <= 0)then
		return 0
	end
	return self.nOwnerID
end

function Class_Equip:getSubType()
	return self.tbCsvBase.SubType
end

function Class_Equip:getType()
	return self.tbCsvBase.Type
end

function Class_Equip:checkHasAllreadyEquiped(tbCard)
	return tbCard:getEquipIDByPos(self.tbCsvBase.Type) > 0
end

function Class_Equip:checkEquipMatchProfession(tbCard)
	if self.tbCsvBase.SubType > 5 then
		return true
	else
		return tbCard:getCsvBase().Profession == self.tbCsvBase.SubType
	end
end

function Class_Equip:getEquipMainProp()
	local nMainProp = (self.tbCsvBase.BaseMainProp + self.tbCsvBase.RefineLevelGrow*self.nRefineLevel)
					*(1+0.08*(self.nLevel - 1))
	return nMainProp
end

function Class_Equip:getEquipMainPropFloor()
	return math.floor(self:getEquipMainProp())
end

--装备强化
function Class_Equip:getEquipMainPropNextStrengthenLvFloor()
	local nMainProp = (self.tbCsvBase.BaseMainProp + self.tbCsvBase.RefineLevelGrow*self.nRefineLevel)
					*(1+0.08*(self.nLevel - 1 + 1))
	return math.floor(nMainProp)
end

--装备精炼
function Class_Equip:getEquipMainPropNextRefineLvFloor()
	local nMainProp = (self.tbCsvBase.BaseMainProp + self.tbCsvBase.RefineLevelGrow*(self.nRefineLevel + 1))
					*(1+0.08*(self.nLevel - 1))
	return math.floor(nMainProp)
end

--装备合成
function Class_Equip:getEquipMainPropNextStarLvFloor()
	local _,CSV_EquipNextSatarLevelInfo = self:getNextEquipStarLevel()
	local nMainProp = (CSV_EquipNextSatarLevelInfo.BaseMainProp + CSV_EquipNextSatarLevelInfo.RefineLevelGrow*self.nRefineLevel)
					*(1+0.08*(self.nLevel - 1))
	return math.floor(nMainProp)
end

--装备合成 当前等级 计算装备数值
--@param nRefineLevel 当前等级 
--在合成的时候等级预览会有降级的情况 (强化等级降低)
function Class_Equip:getEquipLvFloor(nLevel)
	local _,CSV_EquipNextSatarLevelInfo = self:getNextEquipStarLevel()
	local nMainProp = (CSV_EquipNextSatarLevelInfo.BaseMainProp + CSV_EquipNextSatarLevelInfo.RefineLevelGrow*self.nRefineLevel)
					*(1+0.08*(nLevel - 1))
	return math.floor(nMainProp)
end


function g_GetEquipMainProp(CSV_Equip, nRefineLv, nStrengthenLv)
	if(not CSV_Equip or not nStrengthenLv)then
		return 0
	end
	
	--装备主属性 = (基础属性+合成成长属性*当前合成等级)*(1+0.08 *(装备强化等级 - 1))
	local nMainProp = (CSV_Equip.BaseMainProp + CSV_Equip.RefineLevelGrow*nRefineLv)
					*(1+0.08*(nStrengthenLv - 1))
	return math.floor(nMainProp)
end

--[[青铜1~10，强化等级1~10
白银1~10，强化等级11~20
黑铁1~10，强化等级21~30]]
function g_getEquipAtlasNameLev(nStrongthenev)
	if(not nStrongthenev or nStrongthenev <= 0)then
		return 1, "1级"
	end
	
	nStrongthenev = nStrongthenev -1
	local nLayer = math.floor(nStrongthenev/10) + 1 --Atlas 从0开始索引
	local nSubLev = math.mod(nStrongthenev, 10) + 1

	return nLayer, nSubLev.._T("级")
end

function Class_Equip:getEquipServerId()
	return self.nServerID
end

function Class_Equip:setEquipServerId(serverId)
	self.nServerID = serverId
end
function Class_Equip:getEquipCsvID()
	return self.nCsvID 
end 

function Class_Equip:setEquipCsvID(csvID )
	self.nCsvID = csvID 
end 
