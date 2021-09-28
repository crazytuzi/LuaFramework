KuafuLiuJieShowInfoView = KuafuLiuJieShowInfoView or BaseClass(BaseRender)


function KuafuLiuJieShowInfoView:__init()
    self.show_item = {}
    for i = 1, 6 do
        self.show_item[i] = LiuJieShowItem.New(self:FindObj("show_item" .. i))
        self.show_item[i]:SetIndex(i)
    end
end

function KuafuLiuJieShowInfoView:__delete()
    for k, v in pairs(self.show_item) do
        v:DeleteMe()
    end
    self.show_item = nil
end

function KuafuLiuJieShowInfoView:OnFlush()
    local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
    if nil == info or info.kf_battle_list == nil then
        return
    end
    local data_list = info.kf_battle_list
    for i = 1, 6 do
        self.show_item[i]:SetData(data_list[i])
    end
end

local def_prof = 
{
    [1] = 4,
    [3] = 3,
    [4] = 2,
    [5] = 1,
    [6] = 3,
}

local def_sex = 
{
    [1] = 0,
    [3] = 1,
    [4] = 0,
    [5] = 1,
    [6] = 1,
}





LiuJieShowItem = LiuJieShowItem or BaseClass(BaseRender)
function LiuJieShowItem:__init()
    self.display = self:FindObj("Display")
    self.top_text = self:FindVariable("top_text")
    self.title = self:FindObj("Title")

    self.model = RoleModel.New("kuafuliujie_panel")
    self.model:SetDisplay(self.display.ui3d_display)
end

function LiuJieShowItem:__delete()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    if self.ui_title_res then
    	self.ui_title_res:DeleteMe()
    	self.ui_title_res = nil
    end
end
local cfg_pos = 
{
    position = Vector3(-0.4, -0.5, 0), 
    rotation = Vector3(0, 0, 0), 
    scale = Vector3(1.3, 1.3, 1.3)}
local cfg_pos_main = 
{
    position = Vector3(-0.58, -0.75, 0), 
    rotation = Vector3(0, 0, 0), 
    scale = Vector3(1.3, 1.3, 1.3)}
function LiuJieShowItem:SetData(data)
    if nil == data then
        return
    end
    local id = 0
    if self.index == 2 then
        id = 1
    elseif self.index == 1 then
        id = 2
    else
        id = self.index
    end
    self.current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(id - 1).title_name
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local role_res_id = 0
    local weapon_id = 0
    local weapon_id2 = 0
    self.model:ResetRotation()
    local res_index = KuafuGuildBattleData.Instance:GetShowImage(id)
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	local job_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
    -- 有公会占领该地时
    if data.guild_id > 0 then	
    	self.top_text:SetValue(string.format(Language.KuafuGuildBattle.KfGuildShowName,data.guild_name,data.guild_tuanzhang_name .."_s" .. data.server_id))
    	local role_job = job_cfg[data.prof]
        if nil == role_job then
            return
        end
        -- 从职业表中拿到角色模型
    	role_res_id = role_job["model" .. data.sex]
    	for k, v in pairs(fashion_cfg) do
            if res_index == v.index and v["resouce" .. data.prof .. data.sex] then
                -- 主城城主显示时装 index为2代表为主城
            	if self.index == 2 then
                	role_res_id = v["resouce" .. data.prof .. data.sex]
               	end
                -- 如果类型为武器
                if v.part_type == 0 then
                    weapon_id = v["resouce" .. data.prof .. data.sex]
                    -- if data.prof == 3 then
                    -- 	local t = Split(weapon_id,",")
                    -- 	weapon_id = t[1]
                    -- 	weapon_id2 = t[2]
                    -- end
                end
            end
        end
    else
        -- 没有工会占领时
        self.top_text:SetValue(Language.KuafuGuildBattle.KfGuildShowNoOccupy)
        local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
        local role_job = job_cfg[main_role_vo.prof]
        for k, v in pairs(fashion_cfg) do
            if res_index == v.index and v["resouce" .. main_role_vo.prof .. main_role_vo.sex] then
                -- 主城位置显示玩家模型加奖励时装
            	if self.index == 2 then
                	role_res_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
                else
                    -- 其他位置上显示本地配置的职业和性别的模型（策划定的，本地配置的位置在上方）
                    role_res_id = job_cfg[def_prof[self.index]]["model" .. def_sex[self.index]]
               	end
                -- 武器显示
                if v.part_type == 0 then
                    if self.index == 2 then
                        -- 主城城主显示玩家职业对应的时装武器
                        weapon_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
                    else
                        -- 按照上方配置来
                        weapon_id = v["resouce" .. def_prof[self.index] .. def_sex[self.index]]
                    end 
                end
            end
        end
    end
    self.model:SetMainAsset(ResPath.GetRoleModel(role_res_id))
    if self.index == 2 then
        self.model:SetTransform(cfg_pos_main)
    else
        self.model:SetTransform(cfg_pos)
    end
    self.model:SetWeaponResid(weapon_id)
    -- self.model:SetWeapon2Resid(weapon_id2)
    if self.ui_title == nil then
        UtilU3d.PrefabLoad("uis/views/player_prefab", "PlayerTitle", function(obj)
            self.ui_title = obj
            -- local canvas = self.root_node:GetComponent(typeof(UnityEngine.Canvas))
            self.ui_title.transform:SetParent(self.title.transform, false)
            self.ui_title_target = self.ui_title.transform:GetComponent(typeof(UIFollowTarget))
            -- self.ui_title_target.Canvas = canvas

            local variable_table = self.ui_title:GetComponent(typeof(UIVariableTable))
            if variable_table then
                self.ui_title_res = variable_table:FindVariable("title_icon")
                self:SetUiTitle(self.ui_title_res)
            end
            self.ui_title:SetActive(true)
        end)
    end
end

function LiuJieShowItem:SetUiTitle(ui_title_res)
    self.ui_title_res = ui_title_res
    self:FlushTitle()
end

function LiuJieShowItem:FlushTitle()
    local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
    -- self.title_icon:SetAsset(bundle, asset)
    if self.ui_title_res then
        self.ui_title_res:SetAsset(bundle, asset)
    end
end

function LiuJieShowItem:SetIndex(index)
    self.index = index
end
