--------------------------------------------------------------------------------------
-- 文件名:	Class_XianMaiInfo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-5-26 
-- 版  本:	1.0
-- 描  述:	保存在登录的时候下发来的仙脉数据	
-- 应  用:	
---------------------------------------------------------------------------------------

XianMaiInfoData = class("XianMaiInfoData")
XianMaiInfoData.__index = XianMaiInfoData


function XianMaiInfoData:setXianMaiInfo(tbMsg)
	cclog(tostring(tbMsg).."仙脉数据")
	local msgData = tbMsg
	
	local active_info = msgData.active_info		--当前元素激活信息
	local xianmai_lv = msgData.xianmai_lv		--仙脉等级
	local essence = msgData.essence			--精华
	local element_list = msgData.element_list 	--元素个数
	local skill_list = msgData.skill_list		-- 仙脉5个可用技能次数，操作时直接发格子号
	local box_info = msgData.box_info			--仙脉消除表信息
	
	self.tbXianmaiData = {
		xianmai_lv = xianmai_lv,
		active_info = active_info,
		element_list =element_list,
	}
	
	self.tbXianmaiSkillNum = {}
	for i,v in ipairs(skill_list)do
		table.insert(self.tbXianmaiSkillNum,v)
	end
	
	self:setTbBox_info(box_info)
	
end


function XianMaiInfoData:getTbXianmaiSkillNum(index)
	if not  self.tbXianmaiSkillNum then
		 self.tbXianmaiSkillNum = {}
	end

	if not self.tbXianmaiSkillNum[index] then
		local CSV_PlayerXianMaiSkill = g_DataMgr:getCsvConfigByOneKey("PlayerXianMaiSkill",index)
		local addTimes = g_VIPBase:getVipValue("FreeTimes")
		self.tbXianmaiSkillNum[index] = {}
		self.tbXianmaiSkillNum[index] =  CSV_PlayerXianMaiSkill.FreeTimes * addTimes
	end
	
	return self.tbXianmaiSkillNum[index]
end

function XianMaiInfoData:setTbXianmaiSkillNum(index,num)
	if not self.tbXianmaiSkillNum then
		self.tbXianmaiSkillNum = {}
	end
	self.tbXianmaiSkillNum[index] = num
	return self.tbXianmaiSkillNum
end

function XianMaiInfoData:getXianmaiLevel()
	return self.tbXianmaiData.xianmai_lv
end

function XianMaiInfoData:setXianmaiLevel(nLevel)
	self.tbXianmaiData.xianmai_lv = nLevel
	return self.tbXianmaiData.xianmai_lv
end

--激活了那些元素
function XianMaiInfoData:getActiveInfo()
	return self.tbXianmaiData.active_info
end

function XianMaiInfoData:setActiveInfo(active,nIndex,nNum)
	self.tbXianmaiData.active_info = API_SetBitsByPos(active,nIndex,nNum)
	return self.tbXianmaiData.active_info
end

function XianMaiInfoData:setAllByActiveInfo(nNum)
	self.tbXianmaiData.active_info = nNum
	return self.tbXianmaiData.active_info
end

function XianMaiInfoData:setTbBox_info(tb_msg)
	self.tbXianmaiData.box_info = {}
	for i,v in ipairs(tb_msg)do
		self.tbXianmaiData.box_info[i] = {}
		local box_data = v.box_data
		for j,n in ipairs(box_data)do
			self.tbXianmaiData.box_info[i][j] = n
		end
	end
	return self.tbXianmaiData.box_info
end
function XianMaiInfoData:setTbBox_infoByIndex(i,j,value)
	if not self.tbXianmaiData.box_info[i] then
		self.tbXianmaiData.box_info[i] = {}
	end
	self.tbXianmaiData.box_info[i][j] = value
	return self.tbXianmaiData.box_info
end
function XianMaiInfoData:getTbBox_info()
	return self.tbXianmaiData.box_info
end

--拥有的元素数量集合
function XianMaiInfoData:getTbElementList()
	return self.tbXianmaiData.element_list
end

function XianMaiInfoData:setTbElementList(nIndex, nNum)
	self.tbXianmaiData.element_list[nIndex] = nNum
	return self.tbXianmaiData.element_list
end

function XianMaiInfoData:addTbElementDrop(nIndex, nNum)
	self.tbXianmaiData.element_list[nIndex] = self.tbXianmaiData.element_list[nIndex] + nNum
end


function XianMaiInfoData:getTableXianmaiData()
	return self.tbXianmaiData
end

---------------------------------------------------------------------------------
g_XianMaiInfoData = XianMaiInfoData.new()

