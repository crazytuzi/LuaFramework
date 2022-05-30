--[[
    面板上的模型空间
]]

BaseRole = class("BaseRole", function() 
    return ccui.Widget:create()
end)


-- 类型
BaseRole.type = 
{
    role = 0,    --角色外观的       
    partner = 1, --伙伴的 在partner_data表里面的
    unit = 2,
    skin = 3,    --显示皮肤外观
}

--[[
    根据不同类型创建UI上面的展示模型
    @param:vo 这个具体区分
    @param:extend 暂时用于伙伴是否觉醒的标识
    @param:dir 伙伴或者NPC类的默认使用2,其他的使用4
    @param:action_path 因为伙伴或者怪物存在2个动作文件,action和show, 其中action主要是战斗里面的,也用于站前布阵,show是UI展示方面的
    @注意: 因为游戏的改动,这里创建的一律是伙伴模型

]]
function BaseRole:ctor(unit_type, vo, action_path, setting,reversal)
    self.type = unit_type or BaseRole.type.partner
    self.is_load_finish = false
    self.action_path = action_path or PlayerAction.show
    self.reversal = reversal
	self.act_list = {}
    if vo == nil then 
        print("===========> 创建UI模型失败,给了一个空的值")
        return 
    end

    local setting = setting or {}
    --缩放
    local scale = setting.scale or 0.72

    --创建多一个容器，以防外面调用缩放出问题
    self.container = ccui.Widget:create()
    self.container:setScale(scale)
    self:addChild(self.container)

    self.container:setCascadeOpacityEnabled(true) 
	self:setCascadeOpacityEnabled(true)

    -- 待创建的spine资源
    self.spine_list = {}
    if self.type == BaseRole.type.partner then
        local bid = 0
        local star = 0

        --宝可梦皮肤id
        local skin_id = setting.skin_id

        if type(vo) == "number" then
            local config = Config.PartnerData.data_partner_base[vo]
            if config ~= nil then
                bid = config.bid
                star = config.init_star
            end
        elseif type(vo) == "table" then
            --vo 是heroVo对象
            bid = vo.bid or 0
            star = vo.star or 0 
        end
        local key = getNorKey(bid, star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config ~= nil then

            --默认皮肤
            local res = star_config.res_id
            local show_effect = star_config.show_effect

            if skin_id ~= nil and skin_id ~= 0 then
                local skin_config = Config.PartnerSkinData.data_skin_info_fun(skin_id)
                if skin_config and skin_config.res_id ~= nil and skin_config.res_id ~= "" then
                    res = skin_config.res_id
                    if show_effect ~= "" then
                        show_effect = skin_config.show_effect
                    end
                end
            end


            table.insert(self.spine_list, {name="body", res = res, suffix=self.action_path, enable=true,zorder=0})     

            if show_effect and show_effect ~= "" then
                table.insert(self.spine_list, {name="effect", res = show_effect, suffix=PlayerAction.action, enable=true,zorder=1})     
            end
        end
    elseif self.type == BaseRole.type.unit then
        if type(vo) == "number" then
            if PathTool.specialBSModel(vo) then
                self.action_path = PlayerAction.battle_stand
            end
            local config = Config.UnitData.data_unit(vo)
            if config ~= nil then
                table.insert(self.spine_list, {name="body", res=config.body_id, suffix=self.action_path, enable=true,zorder=0}) 
            end  
        end
    elseif self.type == BaseRole.type.role then
        --角色外观的
        if type(vo) == "number" then
            local look_config  = Config.LooksData.data_data[vo]
            if look_config then
                local res = look_config.ico_id
                table.insert(self.spine_list, {name="body", res = res, suffix=self.action_path, enable=true,zorder=0})     
                -- 可能存在的
                local key = getNorKey(look_config.partner_id, look_config.star)
                local star_config = Config.PartnerData.data_partner_star(key)
                if star_config and star_config.show_effect ~= "" then
                    if look_config.skin_id ~= 0 then
                        local skin_config = Config.PartnerSkinData.data_skin_info_fun(look_config.skin_id)
                        if skin_config and skin_config.show_effect ~= "" then
                            table.insert(self.spine_list, {name="effect", res = skin_config.show_effect, suffix=PlayerAction.action, enable=true,zorder=1})     
                        end
                    else
                        table.insert(self.spine_list, {name="effect", res = star_config.show_effect, suffix=PlayerAction.action, enable=true,zorder=1})     
                    end
                end
            end
        end
    elseif self.type == BaseRole.type.skin then
        if type(vo) == "number" then
            --显示皮肤外观
            local skin_id = vo
            local skin_config = Config.PartnerSkinData.data_skin_info_fun(skin_id)
            if skin_config and skin_config.res_id ~= nil and skin_config.res_id ~= "" then
                table.insert(self.spine_list, {name="body", res = skin_config.res_id, suffix=self.action_path, enable=true,zorder=0})  
            end

            if skin_config and skin_config.show_effect ~= "" then
                table.insert(self.spine_list, {name="effect", res = skin_config.show_effect, suffix=PlayerAction.action, enable=true,zorder=1})     
            end
        end
    end
    if self.spine_list == nil or next(self.spine_list) == nil then
        print("==============>  创建模型出错,没有指定资源")
        return
    end
    -- 找到资源类型
    for i,v in ipairs(self.spine_list) do
        if v.name == "body" then
            self.spine_name = v.res
            break
        end
    end
    -- 需要加载的模型数量
    self.load_res_num = #self.spine_list
	self:loadSpineTexture()
    -- self:showShadowUI(true)
end

--显示影子 --by lwc
function BaseRole:showShadowUI(status)
    if status then
        if self.shadow == nil then
            self.shadow = createSprite(PathTool.getResFrame("common", "common_90095"), 0, -210, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, -2)
        else
            self.shadow:setVisible(true)
        end
    else
        if self.shadow then
            self.shadow:setVisible(false)
        end     
    end
end

--[[ 异步加载待创建模型的图片资源 ]]
function BaseRole:loadSpineTexture()
    if tolua.isnull(self) then return end
    local function loadfinish()
        if not self.load_res_num then return end
        self.load_res_num = self.load_res_num - 1
        if self.load_res_num == 0 then
            table.insert(self.act_list, 1, {"addSpineByActionAct", {}})
            self:loadFinish()
        end
    end
    for _, spine_data in pairs(self.spine_list) do
        local js_path, atlas_path, png_path, prefix = PathTool.getSpineByName(spine_data.res, spine_data.suffix)
        if display.isPrefixExist(prefix) then
            loadfinish()
        else
            -- local pixelformal = getPixelFormat(spine_data.res) 
            cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function()
                loadfinish()
            end)
        end
    end
end

--设置是否能透明度
function BaseRole:setCascade(bool)
    if self.container then
        self:setCascadeOpacityEnabled(bool)
        self.container:setCascadeOpacityEnabled(bool)      
    end
 end

function BaseRole:getContainer()
     return self.container
end

function BaseRole:getSpineBoxSize()
    for i,v in ipairs(self.spine_list) do
        if v.name == "body" then
            if v.spine then
                v.spine:update(0)
                return v.spine:getBoundingBox()
            end
        end
    end
    return nil
end

function BaseRole:loadFinish()
    if tolua.isnull(self) then return end
    self.is_load_finish = true
    for _, v in pairs(self.act_list) do 
        self[v[1]](self, unpack(v[2]))
    end
    self.act_list = {}

    if self.reversal ~= nil and self.reversal == true then
        self.container:setScaleX(-1)
    end
end

--==============================--
--desc:创建模型和特效
--time:2019-01-26 09:18:51
--@return 
--==============================--
function BaseRole:addSpineByActionAct()
    if tolua.isnull(self) then return end
    local pos
    for _, spine_data in pairs(self.spine_list) do
        if not tolua.isnull(spine_data.spine) and spine_data.name == "body" then 
            pos = cc.p(spine_data.spine:getPosition())
            spine_data.spine:runAction(cc.RemoveSelf:create())
            spine_data.spine = nil
        end
        -- 角色每次都重新创建
        if spine_data.spine == nil and spine_data.name == "body" then    
            spine_data.spine = self:createSpine(spine_data.res, spine_data.suffix, spine_data.name, spine_data.zorder)
        end

        -- 特效只需要创建一次就好了
        if spine_data.name == "effect" and spine_data.effect == nil then
            spine_data.effect = self:createEffect(spine_data.res, spine_data.suffix, spine_data.zorder)
        end

        if pos then
            if spine_data.spine then 
                spine_data.spine:setPosition(pos)
            end
            if spine_data.effect then
                spine_data.effect:setPosition(pos)
            end
        end
    end
end

-- 创建骨骼
function BaseRole:createSpine(spine_name, action_name, name,zorder)
    if tolua.isnull(self.container) then return end
    if spine_name == nil or spine_name == "" then
        spine_name = "H99999"
    end
    local spine = createSpineByName(spine_name, action_name)
    local zorder = zorder or 2
    local originScale = spine:getScale()
    spine:setPosition(cc.p(0, -170))
    --界面展示在配置的缩放基础上放大
    spine:setScale(1.6 * originScale)
    self.container:addChild(spine, zorder)

    return spine
end

-- 创建特效
function BaseRole:createEffect(spine_name, action_name, zorder) 
    if tolua.isnull(self.container) then return end
    if spine_name == nil or spine_name == "" then
        spine_name = "E99999"
    end
    local effect = createEffectSpine(spine_name, cc.p(0,0), cc.p(0.5,0.5), true, action_name )
    local zorder = zorder or 2
    self.container:addChild(effect, zorder)
    local x = self.container:getScale()
    return effect
end

--==============================--
--desc:设置动作
--time:2019-01-26 09:18:06
--@a:
--@action_name:
--@c:
--@return 
--==============================--
function BaseRole:setAnimation(a, action_name, c)
    a = a or 0
    action_name = action_name or self.action_path
    if c == nil then
        c = true
    end
    if self.is_load_finish then 
        self:setAnimationAct(a, action_name, c)
    else
        table.insert(self.act_list, {"setAnimationAct", {a, action_name, c}})
    end
end

--创建完成后要做的事
function BaseRole:loadFinishCallBack(call_back)
    self.finish_callback = call_back
    if self.is_load_finish then 
        self:finish_callback()
    else
        table.insert(self.act_list, {"finish_callback", {}})
    end
end

function BaseRole:setUnEnabled(status)
    if self.is_load_finish then 
        self:setUnEnabledAct(status)
    else
        table.insert(self.act_list, {"setUnEnabledAct", {status}})
    end
end

function BaseRole:setUnEnabledAct(status)
	setChildUnEnabled(status, self)
end

--==============================--
--desc:设置动作,只需要对模型处理,特效只有一个动作不需要处理
--time:2019-01-26 09:18:20
--@a:
--@action_name:
--@c:
--@return 
--==============================--
function BaseRole:setAnimationAct(a, action_name, c)
    for _, spine_data in pairs(self.spine_list) do 
        if spine_data.enable and spine_data.spine then 
            spine_data.spine:setToSetupPose()
            spine_data.spine:setAnimation(a, action_name, c)
        end
    end
end

function BaseRole:registerSpineEventHandler(...)
    if self.is_load_finish then 
        self:registerSpineEventHandlerAct(...)
    else
        table.insert(self.act_list, {"registerSpineEventHandlerAct", {...}})
    end
end

function BaseRole:registerSpineEventHandlerAct( ... )
    local body_data = keyfind("name", "body", self.spine_list)
    if body_data then 
        body_data.spine:registerSpineEventHandler(...)
    end
end

--[[
    移除自己
]]
function BaseRole:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end