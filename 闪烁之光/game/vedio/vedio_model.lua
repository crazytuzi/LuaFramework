-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-01-24
-- --------------------------------------------------------------------
VedioModel = VedioModel or BaseClass()

function VedioModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function VedioModel:config()
	self.all_vedio_data = {}  -- 全部录像数据
	self.today_like_num = 0   -- 今日点赞数
	self.today_like_is_full = false -- 今日是否点赞数达到最大

	self.filt_lv_flag = true  -- 是否筛选等级相近的玩家录像
	self.is_open_view = false -- 本次登录是否打开过录像馆界面
end

function VedioModel:setPublicVedioData( data )
	if not data then return end
	-- 类型
	if not self.all_vedio_data[data.type] then
		self.all_vedio_data[data.type] = {}
	end
	-- 条件
	if not self.all_vedio_data[data.type][data.cond_type] then
		self.all_vedio_data[data.type][data.cond_type] = {}
	end

	-- 添加录像数据
	if not self.all_vedio_data[data.type][data.cond_type].vedio_data then
		self.all_vedio_data[data.type][data.cond_type].vedio_data = {}
	end
	for i,v in ipairs(data.replay_list) do
		table.insert(self.all_vedio_data[data.type][data.cond_type].vedio_data, v)
	end
	-- 判断一下数据是否已经达到最大值，达到了则不再继续请求数据
	if data.len > #(self.all_vedio_data[data.type][data.cond_type].vedio_data) then
		self.all_vedio_data[data.type][data.cond_type].is_full = false
	else
		self.all_vedio_data[data.type][data.cond_type].is_full = true
	end
end

-- 获取录像大厅数据
function VedioModel:getPublicVedioData( vedioType, cond_type )
	local vedio_data = {}
	if vedioType and cond_type then
		if self.all_vedio_data[vedioType] then
			vedio_data = self.all_vedio_data[vedioType][cond_type] or {}
		end
	end
	return vedio_data
end

-- 更新数据(本地缓存主动更新)
function VedioModel:updateVedioData( vedioType, id, key, val )
	local new_data = {}
	for _,all_data in pairs(self.all_vedio_data) do
		for k,v in pairs(all_data) do
			for m,vData in pairs(v.vedio_data) do
				if vData.id == id then
					vData[key] = val
					new_data = vData
				end
			end
		end
	end
	return new_data
end

-- 是否请求过录像数据
function VedioModel:checkIsReqVedioDataByType( vedioType, cond_type )
	if self.all_vedio_data[vedioType] and self.all_vedio_data[vedioType][cond_type] then
		return true
	end
	return false
end

-- 设置今日点赞数
function VedioModel:setTodayLikeNum( num )
	self.today_like_num = num

	local red_status = false
	self.today_like_is_full = true
	local likes_limit_cfg = Config.VideoData.data_const["likes_limit"]
	if likes_limit_cfg and likes_limit_cfg.val > num then
		red_status = true
		self.today_like_is_full = false
	end
	if self.is_open_view then
		red_status = false
	end
	MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.vedio, red_status)
end

function VedioModel:getTodayLikeNum(  )
	return self.today_like_num
end

function VedioModel:checkTodayLikeIsFull(  )
	return self.today_like_is_full
end

-- 清掉缓存录像数据（关闭录像界面就清掉数据）
function VedioModel:clearVedioData(  )
	self.all_vedio_data = {}
end

-- 缓存一下竞技场分页是否勾选筛选等级相近的玩家
function VedioModel:setFiltLevelFlag( flag )
	self.filt_lv_flag = flag
end

function VedioModel:getFiltLevelFlag(  )
	return self.filt_lv_flag
end

-- 本次登录是否打开过录像馆界面（打开过就不显示红点了）
function VedioModel:setIsOpenView( flag )
	self.is_open_view = flag
end

function VedioModel:__delete()
end