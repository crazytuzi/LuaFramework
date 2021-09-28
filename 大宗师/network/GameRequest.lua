
GameRequest = {}

--param 参数
--callback 回调函数

local _network = require ("utility.GameHTTPNetWork").new()
local function request(msg, callback, errcallback, url)

    msg.acc = game.player.m_uid
    msg.serverKey = game.player.m_serverKey
    
    _network:SendRequest(1, msg, callback, errcallback, url)

end

--英雄
GameRequest.hero = {
    list = function(param, callback)
        local msg = {
            m = "packet",
            a = "list",
            t = 8
        }
        request(msg, callback)
    end

}

--好友聊天

GameRequest.friend = {
        -- 更新聊天列表
    updateChatList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "updateChatList"
        }
        request(msg, _callback,param.errback) 
    end 
}

--武学
GameRequest.skill = {
    list = function(param, callback)
        local msg = {
            m = "packet",
            a = "list",
            t = "4"
        }
        request(msg, callback)
    end,

    sell = function(param, callback)
        local ids = ""
        for _, v in ipairs(param.ids) do
            ids = ids .. tostring(v) .. ","
        end

        if string.sub(ids, string.len(ids)) == ',' then
            ids = string.sub(ids, 1, string.len(ids) - 1)
        end
        local msg = {
            m = "gong",
            a = "sell",
            cids = ids
        }
        request(msg, callback)
    end,

    qianghua = function(param, callback)
        local msg = {
            m = "gong",
            a = "lvUp",
            op = param.op,
            cids = param.cids,
        }
        request(msg, callback)
    end,

    refine = function(param, callback)
        local msg = {
            m = "gong",
            a = "propUp",
            op = param.op,
            id = param.id,
        }
        request(msg, callback)
    end,

}

--装备
GameRequest.equip = {
    list = function(param, callback)
        local msg = {
            m = "packet",
            a = "list",
            t = "1"
        }
        request(msg, callback)
    end,
    qianghua = function(param, callback)
        local msg = {
            m = "equip",
            a = "lvUp",
            id = param.id,
            auto = param.auto
        }
        request(msg, callback)
    end,
    xlstate = function(param, callback)
        local msg = {
            m = "equip",
            a = "propState",
            id = param.id
        }

        request(msg, callback)
    end,
    xl = function(param, callback)
        local msg = {
            m = "equip",
            a = "prop",
            id = param.id,
            t = param.t,
            n = param.num
        }
        request(msg, callback)
    end,
    replace = function(param, callback)
        local msg = {
            m = "equip",
            a = "propRepl",
            id = param.id
        }
        request(msg, callback)
    end
}

--阵容
GameRequest.fmt = {
    list = function(param, callback)
        local msg = {
            m = "fmt",
            a = "list",
            pos = "0",
            acc2 = param.acc2

        }
        request(msg, callback)
    end,

    putOnEquip = function(param, callback)
        assert(param.pos    >= 1 and param.pos <= 6, "装备pos[1, 6]")
        assert(param.subpos >= 1 and param.subpos <= 4, "装备pos[1, 4]" )

        local msg = {
            m = "fmt",
            a = "embattle",
            pos = param.pos,
            subpos = param.subpos,
            id = param.id
        }
        request(msg, callback)
    end,

    putOnSpirit = function(param, callback)
        assert(param.pos    >= 1 and param.pos    <= 6, "装备pos[1, 6]")
        assert(param.subpos >= 7 and param.subpos <= 14, "装备pos[7, 14]" )
        local msg = {
            m = "fmt",
            a = "embattle",
            pos = tostring(param.pos),
            subpos = tostring(param.subpos),
            id = tostring(param.id)
        }
        request(msg, callback)
    end
}

--精元
GameRequest.spirit = {
    list = function(param, callback)
        local msg = {
            m = "packet",
            a = "list",
            t = "6"
        }
        request(msg, callback)
    end,
    start = function(param, callback)
        local msg = {
            m   = "yuan",
            a   = "collect",
            acc = "1",
            t   = param.t
        }
        request(msg, callback)
    end,
    upgrade = function(param, callback)
        local msg = {
            m   = "yuan",
            a   = "lvUp",
            id  = param.id,
            ids = param.ids
        }
        request(msg, callback)
    end
}

--背包
GameRequest.packet = {
    list = function(param, callback)
        local msg = {
            m   = "packet",
            a   = "list",
            t   = "7"
        }
        request(msg, callback)
    end,

    gmAdd = function(param, callback)
        local msg = {
            m   = "packet",
            a   = "gmAdd",
            id = tostring(param.id),
            n  = tostring(param.n),
            t  = tostring(param.t)
        }
        
        request(msg, callback)
    end
}

-- 广播
GameRequest.Broadcast = {
    -- 获取广播列表
    getBroadcastList = function(param)
        local _callback = param.callback
        local msg = {
            m = "broad", 
            a = "list"
        }
        request(msg, _callback)
    end,

    -- 刷新广播列表
    updateList = function(param)
        local _callback = param.callback
        local msg = {
            m = "usr",
            a = "heart"
        }
        request(msg, _callback)
    end
}

GameRequest.game = {
    version = function(param, callback)
        local msg = {
            a = "list"
        }
        request(msg, callback)
    end
}


-- 登陆
GameRequest.login = {
    list = function(param, callback)
        local msg = {
            m     = "usr",
            a     = "enter",
            rid   = "101",
            name  = param.name
        }
        request(msg, callback)
    end,
}

-- 在线奖励
GameRequest.onlineReward = {
    -- 获取在线奖励信息
    list = function(param, callback)
        local msg = {
            m = "gift", 
            a = "onLineCheck"
        }
        request(msg, callback)
    end
}

-- 领奖中心
GameRequest.rewardCenter = {
    -- 获取领奖中心信息
    list = function(param, callback)
        local msg = {
            m = "gift", 
            a = "cList"
        }
        request(msg, callback)
    end
}

-- 聊天相关
GameRequest.chat = {
    -- 获取聊天信息列表
    getList = function(param)
        print("getlist")
        dump(param)
        local _callback = param.callback
        local msg = {
            m = "chat", 
            a = "list", 
            para = param.account,
            type = param.type, 
            name = param.name 
        }
        request(msg, _callback)
    end, 

    -- 发送聊天信息
    sendMsg = function(param)
        local _callback = param.callback
        local msg = {
            m = "chat", 
            a = "send", 
            recname = param.recname,
            type = param.type, 
            msg = param.msg, 
            para1 = param.para1, 
            para2 = param.para2, 
            para3 = param.para3
        }
        request(msg, _callback)
    end, 

    -- 获取未读的消息数量
    getUnRead = function( param )
        local _callback = param.callback
        local msg = {
            m = "chat", 
            a = "unread", 
            type = param.type, 
            name = param.name 
        }
        request(msg, _callback)
    end
}

GameRequest.log = {
    send = function( param )
        local _callback = param.callback
        local msg = {
            m = "help",
            a = "clog",
            type = "client_log",
            info = param.log
        }
        request(msg, _callback)
    end
}

-- 世界boss战相关
GameRequest.worldBoss = {
    -- 伤害排行榜
    rank = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "top" 
        }
        request(msg, _callback)
    end, 

    -- boss战状态
    state = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "state" 
        }
        request(msg, _callback)
    end, 
    
    -- 战斗结果
    result = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "result" 
        }
        request(msg, _callback)
    end 
}

-- 帮派
GameRequest.Guild = {
    -- 检测活动时间 
    checkTime = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "checkTime", 
            id = param.id 
        }
        request(msg, _callback, _errback)
    end,
    
    -- boss实时状态 
    bossState = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossState", 
            unionId = param.unionId, 
        }
        request(msg, _callback, _errback)
    end, 
    
    -- boss活动结果 
    bossResult = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossResult", 
            unionId = param.unionId, 
        }
        request(msg, _callback, _errback)
    end, 
    
}


return GameRequest