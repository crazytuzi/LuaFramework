-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-03-06
-- --------------------------------------------------------------------
PromptModel = PromptModel or BaseClass()

function PromptModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PromptModel:config()
	self.prompt_list = {}
	self.auto_id = 0
end

--==============================--
--desc:判断一条提示是否存在
--time:2017-08-28 04:12:16
--@type:
--@rid:
--@srv_id:
--@return 
--==============================--
function PromptModel:checkIsInList(type, rid, srv_id)
    for i,vo in ipairs(self.prompt_list) do
        if vo.type == type then
            for k,v in pairs(vo.list) do
                local _rid, _srv_id, _rolename = vo:getSridByData(v.data)
                if getNorKey(_rid, _srv_id) == getNorKey(rid, srv_id) then
                    return true
                end
            end
        end
    end
    return false
end

function PromptModel:getPromptVoByType(type)
    for i,v in ipairs(self.prompt_list) do
        if v.type == type then
            return v
        end
    end
end

function PromptModel:addPromptData(data)
    local config = Config.NoticeData.data_get[data.type]
	if config == nil then
		print("==============> 添加小图标失败, 未配置该小图标数据, 类型为 ", data.type)
        return 
	end
    local prompt_vo = nil
	local cur_rid, cur_srv_id = self:getSridByData(data)
    if self:checkIsInList(data.type, cur_rid, cur_srv_id) == true then return end
	self.auto_id = self.auto_id + 1

    if config.can_overly == 1 then
        prompt_vo = self:getPromptVoByType(data.type)
        if prompt_vo == nil then
            prompt_vo = PromptVo.New(data.type, self.auto_id)
            table.insert( self.prompt_list, prompt_vo)
        end
        prompt_vo:update(data)
    else
        prompt_vo = PromptVo.New(data.type, self.auto_id)
        prompt_vo:update(data)
        table.insert( self.prompt_list, prompt_vo)
    end
    GlobalEvent:getInstance():Fire(PromptEvent.ADD_PROMPT_DATA,prompt_vo)
end

--==============================--
--desc:解析职业相关数据
--time:2017-08-28 05:26:47
--@data:
--@return 
--==============================--
function PromptModel:getSridByData(data)
	local rid, srv_id, role_name = 0, "", ""
    local bbs_id = 0
	if data and data.arg_uint32 and #data.arg_uint32 > 0 then
        for i = 1, #data.arg_uint32 do
            local temp = data.arg_uint32[i]
            if temp then
                if temp.key == 1 then
                    rid = temp.value
                elseif temp.key == 2 then
                    bbs_id = temp.value --留言板那边的..表示留言id
                end
            end
        end		
	end

	if data and data.arg_str and #data.arg_str > 0 then
        for i = 1, #data.arg_str do
            local temp = data.arg_str[i]
            if temp then
                if temp.key == 1 then
                    srv_id = temp.value
                elseif temp.key == 2 then
                    role_name = temp.value
                end
            end
        end
	end
	return rid, srv_id, role_name, bbs_id
end

--==============================--
--desc:移除一个提示数据,根据类型和id移除
--time:2017-08-28 05:11:18
--@type:
--@id:
--@return 
--==============================--
function PromptModel:removePromptData(type, id)
    if #self.prompt_list > 0 then
        for i,vo in ipairs(self.prompt_list) do
            if vo.type == type and vo.id == id then
                table.remove(self.prompt_list, i)
                break
            end
        end
        GlobalEvent:getInstance():Fire(PromptEvent.REMOVE_PROMPT_DATA)
    end
end

--根据类型去删除提示数据【例如通过好友图标打开好友界面时候去清理提示数据】
function PromptModel:removePromptDataByTpye(_type)
    if #self.prompt_list > 0 then
        for i,vo in ipairs(self.prompt_list) do
            if vo.type == _type then
                table.remove(self.prompt_list, i) 
                break
            end
        end
        GlobalEvent:getInstance():Fire(PromptEvent.REMOVE_PROMPT_DATA)
    end
end

--检测类型是有灯泡
function PromptModel:checkPromptDataByTpye(_type)
    if #self.prompt_list > 0 then
        for i,vo in ipairs(self.prompt_list) do
            if vo.type == _type then
                return true
            end
        end
    end
    return false
end

-- 根据类型和玩家srv_id以及 rid 移除对象
function PromptModel:removePromptDataByInfo(type, srv_id, rid)
    -- if #self.prompt_list > 0 then
    --     for i = #self.prompt_list, 1, -1 do
    --         local temp_vo = self.prompt_list[i]
    --         if temp_vo.type == type and (temp_vo.srv_id == nil or srv_id == nil or (temp_vo.srv_id == srv_id and temp_vo.rid == rid) )then
    --             table.remove(self.prompt_list, i)
    --             break
    --         end
    --     end
    -- end
    -- GlobalEvent:getInstance():Fire(PromptEvent.REMOVE_PROMPT_DATA)
end

--获取提示信息列表
function PromptModel:getPromptList()
    return self.prompt_list
end

-- 获取列表中是否有未气泡提示的消息
function PromptModel:getNotBubblePrompt(  )
    for k,data in pairs(self.prompt_list) do
        if data.is_show_bubble == false then
            return data
        end
    end
end

function PromptModel:__delete()
end