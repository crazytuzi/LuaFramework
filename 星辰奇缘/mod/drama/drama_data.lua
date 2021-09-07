-- -----------------------
-- 动作数据结构
-- hosr
-- -----------------------
DramaAction = DramaAction or BaseClass()
function DramaAction:__init()
    self.id = 0 --             "Id唯一值"}
    self.type = 0 --           "行动类型(根据类型判断行动规则)"}
    self.need_next = 0 --      "是否需要返回服务器通知下一步(0:不需要 1:需要)"}
    self.time = 0 --           "行动时间"}
    self.mode = 0 --           "行动模式"}
    self.unit_id = 0 --        "单位Id"}
    self.unit_base_id = 0 --   "单位基础Id"}
    self.looks = {} --          "外观效果"} {looks_type, looks_mode, looks_val, looks_str}
    self.battle_id = 0 --      "战场Id"}
    self.mapid = 0 --          "地图Id"}
    self.x = 0 --              "X坐标"}
    self.y = 0 --              "Y坐标"}
    self.val = 0 --            "值"}
    self.ext_val = 0 --        "值"}
    self.res_id = 0 --         "资源ID"}
    self.color = 0 --          "颜色"}
    self.msg = 0 --            "信息"}
    self.ext_msg = 0 --        "附加信息"}
    self.ext_info = 0 --       "附加信息"} {val, msg}
    self.sex = 0 --            "性别"}
    self.classes = 0 --        "职业"}
    self.gain = 0 --           "奖励列表"} {id, val}
end

function DramaAction:SetData(data)
    for k,v in pairs(data) do
        self[k] = v
    end
end

-- -----------------------
-- 剧情数据结构
-- hosr
-- -----------------------
DramaData = DramaData or BaseClass()

function DramaData:__init()
    self.id = 0 -- 剧情ID
    self.name = "" -- 剧情名称
    self.can_skip = 0 -- 是否可跳过(0:否 1:是)
    self.hide_layer = 0 -- 是否隐藏层(0:否 1:是)
    self.action_list = {} -- 动作列表
end

function DramaData:SetData(proto)
    self.id = proto.id
    self.name = proto.name
    self.can_skip = proto.can_skip
    self.hide_layer = proto.hide_layer
    self.action_list = {}
    if proto.action_list ~= nil then
        for i,v in ipairs(proto.action_list) do
            local action = DramaAction.New()
            action:SetData(v)
            table.insert(self.action_list, action)
        end
    end
end
