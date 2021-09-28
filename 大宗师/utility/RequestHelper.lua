--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-19
-- Time: 上午10:27
-- To change this template use File | Settings | File Templates.
--
require("data.data_error_error") 

RequestHelper = {}

local _network = require ("utility.GameHTTPNetWork").new()


local loadingLayer = require("utility.LoadingLayer")
 

--[[
    处理基本的一些errorcode ,from server
]]
local function GameErrorCB( errCode )
    if(errCode == 100011) then                    
        device.showAlert("提示", "您的账号已经在其他设备登陆，请重新登陆！","好的",function ( ... )                     
            -- CSDKShell.Login()        
            game.player.m_logout = true
            display.replaceScene(require("app.scenes.VersionCheckScene").new())
            CSDKShell.onLogout()
        end)
    elseif(errCode == 100014) then
        device.showAlert("提示", "游戏版本错误，请下载新版本！","好的",function ( ... )                       
            -- CSDKShell.Login()        
            game.player.m_logout = true
            display.replaceScene(require("app.scenes.VersionCheckScene").new())
            CSDKShell.onLogout()
        end)
    elseif(errCode == 101) then
        device.showAlert("提示", "sdk异常，请重新登录！","好的",function ( ... )                     
            -- CSDKShell.Login()        
            game.player.m_logout = true
            display.replaceScene(require("app.scenes.VersionCheckScene").new())
            CSDKShell.onLogout()
        end)
    else
        show_tip_label(data_error_error[errCode].prompt)
    end
end



--[[


]]
local function request(msg, callback, errback, url)

    local function cb( data )
        loadingLayer.hide()
        -- dump(data) 
        if data.err ~= nil and data.err~=  "" then
            local errStr = "错误是"..data.err
            if(type(data_error_error[data.errCode]) ~= "nil") then
                -- show_tip_label(data_error_error[data.errCode].prompt)
                GameErrorCB(data.errCode)
            end
            ResMgr.removeMaskLayer()
            if errback ~= nil then
                errback(data)
            end
            return
        end

        if callback then            
            callback(data)
        end
    end

    local function onFailed()
        loadingLayer.hide(function()
            show_tip_label("请重试,网络异常... ... ")
        end)
    end

    loadingLayer.start()

    -- 添加玩家 account
    if game.player.m_uid ~= "" then
        msg.acc = game.player.m_uid
        msg.serverKey = game.player.m_serverKey
    end
    _network:SendRequest(1, msg, cb, onFailed, url)
end


--[[ 
    新手引导
]]
function RequestHelper.setGuide( param )
    local _callback = param.callback
    local msg = {
        m   = "help",
        a   = "setGuide",
        guide = param.guide
    }

    request(msg, _callback)
end

--获得引导值
function RequestHelper.getGuide( param )
    local _callback = param.callback
    local msg = {
        m   = "help",
        a   = "getGuide",
        -- guide = param.guide
    }

    request(msg, _callback)
end 

--[[ ------------
新手引导
]]


function RequestHelper.getGuide( param )
    local _callback = param.callback
    local msg = {
        m   = "help",
        a   = "getGuide",
        -- guide = param.guide
    }

    request(msg, _callback)
end 

--[[
    《--酒剑仙/剪子包袱锤
]]




--猜拳初始化信息 http://test.game.com:4001/activity/guessinfo?m=activity&a=guessinfo&acc=simulate__1412853710
function RequestHelper.getGuessInfo(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "guessinfo",
        
    }

    request(msg, _callback)
end
--猜拳  http://test.game.com:4001/activity/guessing?m=activity&a=guessing&acc=simulate__1412853710
function RequestHelper.guessing(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "guessing",
      
    }

    request(msg, _callback)
end

--翻牌 http://test.game.com:4001/activity/guesschoose?m=activity&a=guesschoose&pos=0&acc=simulate__1412853710
function RequestHelper.guessChoseCard(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "guesschoose",
        pos = param.pos
    }

    request(msg, _callback)

end
--购买猜拳次数 http://test.game.com:4001/activity/guessbuy?m=activity&a=guessbuy&acc=simulate__1412853710
function RequestHelper.buyGuessTime(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "guessbuy",       
    }

    request(msg, _callback)
end
--[[
    酒剑仙/剪子包袱锤--》
]]
--获取各个活动的状态
function RequestHelper.getActStatus(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "status",       
    }
    request(msg, _callback)
end



--[[
    活动副本购买次数
]]

function RequestHelper.buyActTimes(param)
    local _callback = param.callback
    local msg = {
        m   = "actbattle",
        a   = "actBuy",     
        aid = param.aid,
        act = param.act  
    }

    request(msg, _callback)
end

--[[
    精英副本购买次数
]]

function RequestHelper.buyEliteTimes(param)
    local _callback = param.callback
    local msg = {
        m   = "actbattle",
        a  =  "buyElite",
    }

    request(msg, _callback)
end

--[[
    普通副本购买次数
]]

function RequestHelper.buyBatTimes(param)
    local _callback = param.callback
    local msg = {
        m = "battle",
        a = "batBuy",
        id = param.id,
        act = param.act  
    }
    dump(param.errback)
    request(msg, _callback, param.errback)
end



function RequestHelper.setDramaValue( data )
    local _callback = data.callback
    local msg = {
        m   = "help",
        a   = "setUserParam",
        type = "helpStoryStep",
        param = data.param
    }

    request(msg, _callback)
end
--获得剧情值
function RequestHelper.getDramaValue(data)
    local _callback = data.callback
    local msg = {
        m   = "help",
        a   = "getUserParam",
        type = "helpStoryStep",
    }

    request(msg, _callback)
end 


--[[-------------------------------------------------------]]
-- 获取玩家基本信息，更新主界面信息
function RequestHelper.getBaseInfo( param )
    local _callback = param.callback
    local msg = {
        m   = "usr",
        a   = "playerInfo",
    }

    request(msg, _callback)
end

-- get 公告
function RequestHelper.getNotice( param )
    local _callback = param.callback
    local msg = {
        m = "usr",
        a = "getNotice",
    }

    request(msg, _callback)
end

--背包列表
function RequestHelper.getBag(param)

    local _callback = param.callback
    local msg = {
        m   = "packet",
        a   = "list",
        acc = "1",
        t   = 7
    }

    request(msg, _callback)
end

--卖出道具
function RequestHelper.sell(param)
    local _callback = param.callback
    local ids = ""
    for _, v in ipairs(param.ids) do
        ids = ids .. tostring(v) .. ","
    end

    if string.sub(ids, string.len(ids)) == ',' then
        ids = string.sub(ids, 1, string.len(ids) - 1)
    end

    local msg = {
        m   = "packet",
        a   = "sell",
        acc = "1",
        ids = ids,
    }

    request(msg, _callback)
end

--侠客加锁
function RequestHelper.lockHero(param)
    local _callback = param.callback
    local msg = {
        m    = "card",
        a    = "lock",
        id   = param.id,
        lock = param.lock
    }
    --0解锁/1锁定
    request(msg, _callback)

end

--添加到背包
function RequestHelper.addToBag(param)
    local _callback = param.callback
    local msg = {
        m    = "packet",
        a    = "add",
        acc  = "1",
        item = param.item,
    }

    request(msg, _callback)
end

function RequestHelper.useItem(param)
    local _callback = param.callback
    local msg = {
        m   = "packet",
        a   = "use",
        id  = param.id,
        num = param.num

    }

    request(msg, _callback)
end

--背包扩展
function RequestHelper.extendBag(param)
    local _callback = param.callback
    local msg = {
        m   = "packet",
        a   = "extend",
        type= param.type
    }

    request(msg, _callback)
end

--酒馆招募
function RequestHelper.recrute(param)
    local _callback = param.callback
    local _t        = param.t   --类型
    local _n        = param.n   --数量
    local msg = {
        m    = "shop",
        a    = "wine",
        acc  = 1,
        t    = _t,
        n    = _n
    }
    request(msg, _callback)
end

--酒馆状态
function RequestHelper.getPubStat(param)
    local _callback = param.callback
    local msg = {
        m   = "shop",
        a   = "stat",
        acc = 1
    }

    request(msg, _callback)
end

--商店列表
function RequestHelper.getShopList(param)
    local _callback = param.callback
    local msg = {
        m = "shop",
        a = "list",
        acc = 1
    }

    request(msg, _callback)
end

--商店购买
function RequestHelper.buy(param)
    local auto = param.auto or 0
    local _callback = param.callback
    local msg = {
        m = "shop",
        a = "buy",
        id  = param.id,
        n  = param.n,
        coinType = param.coinType,
        coin = param.coin,
        auto = auto       

    }

    request(msg, _callback, param.errback)
end


--战斗大地图
function RequestHelper.getLevelList(param)
    local _callback = param.callback
    local msg = {
        m      = "battle",
        a      = "world",
        acc    = 1,
        id     = param.id
    }

    request(msg, _callback)
end

function RequestHelper.getSubLevelList(param)
    local _callback = param.callback
    local msg = {
        m      = "battle",
        a      = "field",
        acc    = 1,
        id     = param.id
    }

    request(msg, _callback)
end

--获得装备列表
function RequestHelper.getEquipList(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "list",
        t = 1
        
    }
    request(msg, _callback)
end

--装备强化
function RequestHelper.sendEquipQianghuaRes(param)
    local _callback = param.callback
    local msg = {
        m = "equip",
        a = "lvUp",
        auto = param.auto,
        id = param.id
        
    }
    request(msg, _callback)
end

--装备洗炼预览
function RequestHelper.sendEquipXiLianPropRes(param)
    local _callback = param.callback
    local msg = {
        m = "equip",
        a = "propState",
        id = param.id        
    }
    request(msg, _callback)
end 

--装备洗炼
function RequestHelper.sendEquipXiLianRes(param)
    local _callback = param.callback
    local msg = {
        m = "equip",
        a = "prop",
        t = param.t,
        n = param.n,
        id = param.id        
    }
    request(msg, _callback)
end 

--获得装备碎片
function RequestHelper.getEquipDebrisList(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "list",
        t = 3
    }

    request(msg, _callback)
end

--发送合成装备碎片请求
function RequestHelper.sendHeChengEquipRes(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "use",
        id = param.id,
        num = param.num
    }

    request(msg, _callback)
end


--发送替换洗炼属性请求
function RequestHelper.sendTiHuanEquipRes(param)
    local _callback = param.callback
    local msg = {
        m = "equip",
        a = "propRepl",
        id = param.id,
        num = param.num
    }

    request(msg, _callback)
end

--发送出售装备请求
function RequestHelper.sendSellEquipRes(param)
    local _callback = param.callback
    local msg = {
        m = "equip",
        a = "sell",
        eids = param.ids
        
    }

    request(msg, _callback)
end

-- gm命令
function RequestHelper.gmAdd(param)
    local _callback = param.callfunc
    local msg = {
        m = "packet",
        a = "gmAdd",
        acc = 1,
        id = tostring(param.id),
        n  = tostring(param.n),
        t  = tostring(param.t)
    }
    request(msg, _callback)
end

-- gm一次加所有卡
function RequestHelper.gmAddAllCard(param)
    local _callback = param.callfunc
    local msg = {
        m = "gmCard",
        a = "allCard",
    }
    request(msg, _callback)
end

-- 重置所有挑战次数
function RequestHelper.gmResetAllCounts( param )
    local _callback = param.callfunc
    local msg = {
        m = "help",
        a = "setUserParam",
        type = "actPveCnts",
        param = {0,0,0}
    }
    request(msg, _callback)
end

-- 添加副本星星数量
function RequestHelper.gmAddStar(param)
    local _callback = param.callfunc
    local msg = {
        m = "channel",
        a = "addStar",
        num = "1000",

    }
    request(msg, _callback)
end

--获得侠客列表
function RequestHelper.getHeroList(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "list",
        t = "8",
        
    }
    request(msg, _callback)
end

RequestHelper.split = {
    status = function(param)
        local _callback = param.callback
        local msg = {
            m = "furnace",
            a = "flist",
            acc = 1
        }
        request(msg, _callback)
    end,
    refine = function(param)
        local _callback = param.callback
        local msg = {
            m = "furnace",
            a = "furnace",
            type = param.t,
            ids = param.ids
        }
        request(msg, _callback)
    end,
    reborn = function(param)
        local _callback = param.callback
        local msg = {
            m = "furnace",
            a = "reborn",
            type = param.t,
            id = param.id
        }
        request(msg, _callback)
    end
}

--获得侠客残魂列表
function RequestHelper.getHeroDebrisList(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "list",
        t = 5
        
    }
    request(msg, _callback)
end

--[[
    获得限时神将数据
]]

function RequestHelper.getLimitInitData(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "limitCard"
    }

    request(msg, _callback)
end

--获得神将
function RequestHelper.drawLimitHero(param)
    local _callback = param.callback
    local msg = {
        m   = "activity",
        a   = "LimitDraw",
        isFree = param.isFree
    }

    request(msg, _callback)   

end




--发送合成卡牌碎片请求
function RequestHelper.sendHeChengHeroRes(param)
    local _callback = param.callback
    local msg = {
        m = "packet",
        a = "use",
        id = param.id,
        num = param.num
    }
    request(msg, _callback)
end

--发送出售卡牌请求
function RequestHelper.sendSellCardRes(param)
    local _callback = param.callback
    local msg = {
        m = "card",
        a = "sell",
        cids = param.ids
    }

    request(msg, _callback)
end


--阵法
RequestHelper.formation = {
    list = function(param)
        local _callback = param.callback
        local msg = {
            m = "fmt",
            a = "list",
            pos = "0",
            acc2 = param.acc2

        }
        request(msg, _callback)
    end,
    putOnEquip = function(param) --装备武学
        assert(param.pos    >= 1 and param.pos <= 6, "装备pos[1, 6]")

        local _callback = param.callback
        local msg = {
            m = "fmt",
            a = "embattle",
            pos = param.pos,
            subpos = param.subpos,
            id = param.id

        }
        request(msg, _callback)
    end,
    putOnSpirit = function(param)
        assert(param.pos    >= 1 and param.pos    <= 6, "装备pos[1, 6]")
        assert(param.subpos >= 7 and param.subpos <= 14, "装备pos[7, 14]" )

        local _callback = param.callback
        local msg = {
            m = "fmt",
            a = "embattle",
            pos = tostring(param.pos),
            subpos = tostring(param.subpos),
            id = tostring(param.id)
        }
        request(msg, _callback)
    end,
    set = function(param)
        local _callback = param.callback
        local msg = {
            m = "fmt",
            a = "embattle",
            subpos = "0",
            id = param.id,
            pos = param.pos

        }
        request(msg, _callback)
    end,
    unload = function(param)
        local _callback = param.callback
        local msg = {
            m   = "fmt",
            a   = "unload",
            pos = param.pos
        }
        request(msg, _callback)
    end, 

    -- 对方阵容
    enemyList = function(param)
        local _callback = param.callback
        local msg = {
            m = "fmt", 
            a = "list", 
            pos = "0", 
            acc2 = param.enemyAcc 
        }
        request(msg, _callback)
    end,
    quickEquip = function(param)
        local _callback = param.callback
        local _errback = param.errback
        local msg = {
            m = "fmt",
            a = "fastChangeEquip",
            pos = param.pos,
            cardId = param.cardId,
            type = param.type
        }
        request(msg, _callback,_errback)
    end
}

--发送卡牌进阶请求
function RequestHelper.getJinJieRes(param)
    local _callback = param.callback
    local msg = {
        m = "card",
        a = "clsUp",
        op = param.op,
        id = param.id
        
    }
    request(msg, _callback)

end
--发送竞技场请求
function RequestHelper.getArenaData(param)
    local _callback = param.callback
    local msg = {
        m = "arena",
        a = "list"
        -- op = param.op,
        -- id = param.id
        
    }
    request(msg, _callback)
end

--发送竞技场排行请求
function RequestHelper.getArenaRank(param)
    local _callback = param.callback
    local msg = {
        m = "arena",
        a = "rlist"
        -- op = param.op,
        -- id = param.id
        
    }
    request(msg, _callback)
end


--发送卡牌强化请求
function RequestHelper.getCardQianghuaRes(param)
    local _callback = param.callback
    local _errback = param.errback
    local msg = {
        m = "card",
        a = "lvUp",
        op = param.op,
        cids = param.cids,
    }
    request(msg, _callback,_errback)
end

RequestHelper.hero = {
    info = function(param)
        local _callback = param.callback
        local msg = {
            m = "card",
            a = "msg",
            cid = param.cid
        }
        request(msg, _callback)
    end,

    shentongReset = function(param)
        local _callback = param.callback
        local msg = {
            m = "card",
            a = "shenReset",
            id = param.cid
        }
        request(msg, _callback)
    end,
    shentongUpgrade = function(param)
        local _callback = param.callback
        local msg = {
            m = "card",
            a = "shenUp",
            id = param.cid,
            ind = param.ind
        }
        request(msg, _callback)
    end
}

--精元
RequestHelper.spirit = {
    list = function(param)
        local _callback = param.callback
        local msg = {
            m = "packet",
            a = "list",
            t = "6"
        }
        request(msg, _callback)
    end,
    start = function(param)
        local _callback = param.callback
        local msg = {
            m   = "yuan",
            a   = "collect",
            acc = "1",
            t   = param.t
        }
        request(msg, _callback)
    end,
    upgrade = function(param)
        local _callback = param.callback
        local msg = {
            m   = "yuan",
            a   = "lvUp",
            id  = param.id,
            ids = param.ids
        }
        request(msg, _callback)
    end,
    nbstart = function(param)
        local _callback = param.callback
        local msg = {
            m   = "yuan",
            a   = "useItem"
        }
        request(msg, _callback)
    end

}

--装备
RequestHelper.equip = {
    list = function(param)
        local _callback = param.callback
        local msg = {
            m = "packet",
            a = "list",
            t = "1"
        }
        request(msg, _callback)
    end
}


--发送侠魂强化请求
function RequestHelper.getXiaHunQianghuaRes(param)
    local _callback = param.callback
    local msg = {
        m = "card",
        a = "soulUp",
        op = param.op,
        id = param.id,
        n = param.n
        
    }
    request(msg, _callback)

end

--发送阵容请求
function RequestHelper.sendZhenRongRes(param)
    local _callback = param.callback
    local msg = {
        m = "fmt",
        a = "embattle",
        subpos = "0",
        id = param.id,
        pos = param.pos
        
    }
    request(msg, _callback)

end



function RequestHelper.getKongFuList(param)
    local _callback = param.callback

    local msg = {
        m = "packet",
        a = "list",
        t = "4"
    }
    request(msg, _callback)

end

function RequestHelper.sendKongFuQiangHuaRes(param)
    local _callback = param.callback
    local msg = {
        m = "gong",
        a = "lvUp",
        op = param.op,
        cids = param.cids,      
    }
    request(msg, _callback)
end

--[[
    活动副本 list
]]
function RequestHelper.HuoDongFuBenList( param )
    dump(param)
    local _callback = param.callback
    local msg = {
        m = "actbattle",
        a = "actPveState",
     
    }
    request(msg, _callback)
end


--[[
    精英副本 list
]]
function RequestHelper.JingyingFuBenList( param )
    dump(param)
    local _callback = param.callback
    local msg = {
        m = "actbattle",
        a = "elite",
     
    }
    request(msg, _callback)
end

--[[
    精英副本 战斗
]]
function RequestHelper.JingyingFuBenBattle( param )
    local _callback = param.callback
    local msg = {
        m = "actbattle",
        a = "elitePve",
        id = param.id,
        npc = param.npc
     
    }
    request(msg, _callback)
end

function RequestHelper.getItemSaleData(param) --获取商品的可出售信息 主要用来查看体力丹  耐力丹等物品
    local _callback = param.callback
    local msg = {
        m = "shop",
        a = "oList",
        id = param.id
     
    }
    request(msg, _callback)
end


RequestHelper.channel = {

--  经脉界面
    info = function(param)
        local _callback = param.callback
        local msg = {
            m = "channel",
            a = "main",

        }
        request(msg, _callback)
    end,

--  升级
    upgrade = function(param)
        local _callback = param.callback
        local msg = {
            m = "channel",
            a = "lvUp",
            t = param.t

        }
        request(msg, _callback)
    end,

--  洗经伐脉
    reset = function(param)
        local _callback = param.callback
        local msg = {
            m = "channel",
            a = "reset",

        }
        request(msg, _callback)
    end
}

-- 获得竞技场战斗数据
function RequestHelper.ArenaBattle( param )
    local _callback = param.callback
    local msg = {
        m = "arena",
        a = "dare",
        -- acc2 = param.acc2,
        rank = param.rank
     
    }
    request(msg, _callback)
end

function RequestHelper.JingYingBattle( param ) --获得精英战斗的信息
    local _callback = param.callback
    local msg = {
        m = "actbattle",
        a = "elitePve",
        id = param.id
        
     
    }
    request(msg, _callback)
end

function RequestHelper.HuoDongBattle( param ) --获得精英战斗的信息
    local _callback = param.callback
    local msg = {
        m = "actbattle",
        a = "actPve",
        aid = param.aid,
        npc = param.npc
        -- id = param.id
        
     
    }
    request(msg, _callback)
end

RequestHelper.dailyLoginReward = {
    -- 获取签到信息
    getInfo = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "signCheck"
        }
        request(msg, _callback)
    end, 

    -- 获得签到奖励
    getReward = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "signGet", 
            day = param.day
        }
        request(msg, _callback)
    end
}

RequestHelper.levelReward = {
    -- 获取等级礼包信息
    getInfo = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "lvCheck"
        }
        request(msg, _callback)
    end, 

    -- 获得等级礼包
    getReward = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "lvGet", 
            lv = param.level
        }
        request(msg, _callback)
    end
}


RequestHelper.kaifuReward = {
    -- 获取等级礼包信息
    getInfo = function(param)
        local _callback = param.callback
        local msg = {
            m = "logingift", 
            a = "loginCheck"
        }
        request(msg, _callback)
    end, 

    -- 获得等级礼包
    getReward = function(param)
        local _callback = param.callback
        local msg = {
            m = "logingift", 
            a = "getGift", 
            day = param.day 
        }
        request(msg, _callback)
    end
}


RequestHelper.game = {

    -- 服务器列表
    -- serverList = function ( param )
    --     local _callback = param.callback
    --     local msg = {
    --         m     = "login",
    --         a     = "list",           
    --     }
    --     request(msg, _callback)
    -- end,

    -- 登陆
    login = function(param)
        local _callback = param.callback
        local msg = {
            m     = "usr",
            a     = "enter",
            rid   = param.roleId,
            name  = param.name
        }
        request(msg, _callback)
    end,

    -- 注册
    register = function ( param )
        dump(param)
        local deviceinfo = CSDKShell.GetDeviceInfo()
        dump(deviceinfo)
        local _callback = param.callback
        local msg = {
            a = "reg",
            m = "usr",
            SessionId  =  param.sessionId,
            uac        =  param.acc,
            name       =  param.name, 
            rid        =  param.rid, 
            deviceinfo =  deviceinfo,
            loginName  =  game.player.m_loginName,
            platformID =  param.platformID
        }
        request(msg, _callback)
    end,
    -- 第三方sdk登陆
    loginGame = function ( param )
        dump(param)
        local deviceinfo = CSDKShell.GetDeviceInfo()
        dump(deviceinfo)
        local _callback = param.callback
        local msg = {
            a         = "login",
            m         = "usr",
            SessionId =  param.sessionId,
            uac       =  param.uin,
            deviceinfo = deviceinfo,
            loginName  = game.player.m_loginName,
            -- name      =  param.name, 
            -- rid       =  param.rid 
            platformID = param.platformID
        }
        request(msg, _callback)
    end
}

RequestHelper.rewardCenter = {
    -- 获取领奖中心信息
    getInfo = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "cList"
        }
        request(msg, _callback)
    end, 

    -- 获得领奖中心的奖励
    getReward = function(param)
        local t = 1
        if param.isGetAll then t = 2 end

        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "cGet", 
            t = t, 
            objId = param.objId
        }
        request(msg, _callback)
    end
}

-- 在线奖励相关
RequestHelper.onlineReward = {
    -- 获取在线奖励信息
    getRewardList = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "onLineCheck"
        }
        request(msg, _callback)
    end, 

    -- 获取奖励
    getReward = function(param)
        local _callback = param.callback
        local msg = {
            m = "gift", 
            a = "onLineGet"
        }
        request(msg, _callback)
    end
}



function RequestHelper.sendRankListReq(param)
    local _callback = param.callback
    local msg = {
        m = "rank",
        a = "list",
        type = param.listType
    }
    request(msg, _callback)
end


function RequestHelper.getRewardCenter(param)
    local _callback = param.callback
    local msg = {
        m = "arena",
        a = "reward",
    }
    request(msg, _callback)
end

--[[
    检查竞技场是否已经发生了改变
]]
function RequestHelper.sendCheckRankList(param)
local _callback = param.callback
    local msg = {
        m = "arena",
        a = "check",
        acc2 = param.acc2,
        rank = param.rank
    }

    request(msg, _callback)
end

--[[
    获取玩家信息 
]]
function RequestHelper.getPlayerInfo( param )
    local _callback = param.callback
    local msg = {
        m = "card",
        a = "uinfo",
     
    }
    request(msg, _callback)
end


--[[
    精彩活动
]]
RequestHelper.nbHuodong = {

    -- 客栈状态
    state = function ( param )
        local _callback = param.callback
        local msg = {
            m = "usr",
            a = "sleep",
         
        }
        request(msg, _callback)
    end,

    -- 客栈休息
    sleep = function ( param )
        local _callback = param.callback
        local msg = {
            m = "usr",
            a = "sleepOp",
         
        }
        request(msg, _callback)
    end

}

-- 夺宝相关
RequestHelper.Duobao = {
    -- 获取内外功列表
    getNeiWaiGongList = function(param)
        local _callback = param.callback
        local msg = {
            m = "snatch", 
            a = "list"
        }
        request(msg, _callback)
    end, 

    -- 合成
    synth = function(param)
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "snatch", 
            a = "synth", 
            id = param.id, 
            t = param.t
        }
        request(msg, _callback, _errback)
    end, 

    -- 获取被抢夺列表
    getSnatchList = function(param)
        local _callback = param.callback
        local msg = {
            m = "snatch", 
            a = "sList", 
            id = param.id
        }
        request(msg, _callback)
    end, 

    -- 抢夺
    snatch = function(param)
        local _callback = param.callback
        local msg = {
            m = "snatch", 
            a = "snatch", 
            id = param.id, 
            data = param.data
        }
        request(msg, _callback)
    end, 

    -- 使用免战牌
    useMianzhan = function(param)
        local _callback = param.callback
        local msg = {
            m = "snatch", 
            a = "use", 
            t = param.t
        }
        request(msg, _callback)
    end
}

--普通战斗
function RequestHelper.sendNormalBattle( param )
    local _callback = param.callback
    local msg = {
        m = "battle",
        a = "pve",
        id = param.id,
        type = param.type
     
    }
    request(msg, _callback)
end

-- 邮件相关
RequestHelper.Mail = {
    -- 获取邮件列表
    getMailList = function(param)
        local _callback = param.callback
        local msg = {
            m = "mail", 
            a = "mlist", 
            type = param.type, 
            mailId = param.mailId 

        }
        request(msg, _callback)
    end, 

    -- 向好友发送邮件
    sendMail = function(param)
        local _callback = param.callback
        local msg = {
            m = "mail", 
            a = "sendFriend", 
            recname = param.recname, 
            msg = param.msg

        }
        request(msg, _callback)
    end
}

--领取副本战斗关卡奖励
function RequestHelper.getBattleReward( param )
    local _callback = param.callback
    local msg = {
        m = "battle",
        a = "award",
        id = param.id,
        t = param.t
    }
    request(msg, _callback)
end

--获取图鉴信息
function RequestHelper.getHandBook( param )
    local _callback = param.callback
    local msg = {
        m = "handbook",
        a = "getAll"
    }
    request(msg, _callback)
end


-- 连战相关
RequestHelper.lianzhan = {
    -- 清除连战冷却时间
    clearCDTime = function(param)
        local _callback = param.callback
        local msg = {
            m = "battle", 
            a = "cdClear", 
            id = param.id, 
            t = param.t
        }
        request(msg, _callback)
    end, 

    -- 连战
    battle = function(param)
        local _callback = param.callback
        local msg = {
            m = "battle", 
            a = "pves", 
            id = param.id, 
            type = param.type, 
            n = param.n 
        }
        request(msg, _callback)
    end
}

-- 聊天相关
RequestHelper.chat = {
    -- 获取聊天信息列表
    getList = function(param)
        local _callback = param.callback
        local msg = {
            m = "chat", 
            a = "list", 
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
    end
}

RequestHelper.jianghu = {
    list = function(param)
        local _callback = param.callback
        local msg = {
            m = "road",
            a = "list",
        }
        request(msg, _callback)
    end,
    send = function(param)
        local _callback = param.callback
        local msg = {
            m = "road",
            a = "use",
            cardId = param.cardId,
            itemId = param.itemId,
            multi = param.multi
        }
        request(msg, _callback)
    end
}


-- 请求竞技场兑换相关 
RequestHelper.exchange = {
    --由于论剑商城和竞技场兑换一致 所以
    --竞技场兑换里传type为2 就能获取论剑商城数据
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "arena", 
            a = "excList", 
            shopType = param.shopType
        }
        request(msg, _callback)
    end,

    exchange = function(param) 
        local _callback = param.callback 
        local msg = {
            m = "arena", 
            a = "exchange", 
            id = param.id, 
            shopType = param.shopType,
            num = param.num 
        }
        request(msg, _callback)
    end
}


-- CDKey 
function RequestHelper.getCDKeyReward( param )
    local _callback = param.callback
    local msg = {
        m = "gift",
        a = "cdkey",
        pfid = param.pfid, 
        cdkey = param.cdkey 
    }
    request(msg, _callback)
end 


-- 神秘商店相关
RequestHelper.shenmi = {
    -- 获取列表相关信息
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "shenmi", 
            a = "list", 
            refresh = param.refresh 
        }
        request(msg, _callback)
    end, 

    -- 检测时间
    checkTime = function(param)
        local _callback = param.callback 
        local msg = {
            m = "shenmi", 
            a = "verify" 
        }
        request(msg, _callback)
    end, 

    -- 兑换
    exchange = function(param)
        local _callback = param.callback 
        local msg = {
            m = "shenmi", 
            a = "exchange", 
            id = param.id 
        }
        request(msg, _callback)
    end
}


-- 世界boss战相关
RequestHelper.worldBoss = {
    -- 检测活动开始状态
    history = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "history" 
        }
        request(msg, _callback)
    end, 

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

    -- 鼓舞/复活
    pay = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "pay", 
            use = param.use 
        }
        request(msg, _callback)
    end, 

    -- 战斗
    battle = function(param)
        local _callback = param.callback 
        local msg = {
            m = "bossbattle", 
            a = "pve" 
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

--[[
    游戏充值与购买元宝
    1. iap list
    2. 购买 state

]] 

RequestHelper.GameIap = {
    main = function ( param )
        dump(param)
        local _callback = param.callback 
        local msg = {
            m = "iap", 
            a = "main" 
        }
        dump(msg)
        request(msg, _callback)
    end,
    
}


RequestHelper.monthCard = {
    -- 获取月卡信息
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "mCard", 
            a = "actPage"
        }
        request(msg, _callback) 
    end, 

    -- 领取每日奖励
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "mCard", 
            a = "get"
        }
        request(msg, _callback) 
    end 
}

RequestHelper.huashan = {
    state = function(param)
        local _callback = param.callback
        local msg = {
            m = "swordfight",
            a = "enterSword"
        }
        request(msg, _callback, param.error)
    end,
    zhandouli = function(param)
        local _callback = param.callback
        local msg = {
            m = "swordfight",
            a = "combat",
            fmt = param.fmt
        }
        request(msg, _callback)
    end,
    fight = function(param)
        local _callback = param.callback
        local msg = {
            m = "swordfight",
            a = "fight",
            floor = param.floor,
            fmt = param.fmt
        }
        request(msg, _callback)
    end,
    reset = function(param)
        local _callback = param.callback
        local msg = {
            m = "swordfight",
            a = "reset",
            gold = param.gold
        }
        request(msg, _callback)
    end,
    getaward = function(param)
        local _callback = param.callback
        local msg = {
            m = "swordfight",
            a = "award",
            floor = param.floor
        }
        request(msg, _callback)
    end
}

RequestHelper.vipFuli = {
    -- 获取vip信息
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "iap", 
            a = "vipDayGift"
        }
        request(msg, _callback) 
    end, 

    -- 领取每日奖励
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "iap", 
            a = "getVipDayGift"
        }
        request(msg, _callback) 
    end 
}

RequestHelper.vipLibao = {
    -- 礼包列表界面
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "iap", 
            a = "vipLvGiftList"
        }
        request(msg, _callback) 
    end, 

    -- VIP等级礼包领取
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "iap", 
            a = "vipLvGiftGet", 
            vipLv = param.vipLv 
        }
        request(msg, _callback) 
    end 
}

RequestHelper.leijiLogin = {
    -- 礼包列表
    getListData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "happyGift"
        }
        request(msg, _callback) 
    end, 

    -- 礼包相关状态
    getStatusData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "happyStatus"
        }
        request(msg, _callback) 
    end, 

    -- 礼包领取
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "happyGet", 
            day = param.day 
        }
        request(msg, _callback) 
    end 
}

-- 月签 
RequestHelper.yueqian = {
    -- 状态  
    monthSignStatus = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "monthSignStatus"
        }
        request(msg, _callback) 
    end, 

    -- 领取
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "monthSignGet", 
            day = param.day ,
            month = param.month,
        }
        request(msg, _callback,param.errback) 
    end 
}

-- 等级投资 
RequestHelper.dengjiTouzi = {
    -- 状态  
    getData = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "investPlanStatus" 
        }
        request(msg, _callback) 
    end, 

    -- 领取
    getReward = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "investPlanGet", 
            lv = param.lv 
        }
        request(msg, _callback) 
    end, 

    -- 购买 
    buy = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "investPlanBuy", 
            lv = param.lv 
        }
        request(msg, _callback) 
    end 
}

--  帮派
RequestHelper.Guild = {
    -- 主界面信息
    main = function( param )
        local _callback = param.callback
        local msg = {
            m = "union",
            a = "enterUnion", 
            num = param.num 
        }
        request(msg, _callback)
    end,

    -- 帮派申请
    apply = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "applyUnion", 
            uid = param.id, 
            type = param.type 
        }
        request(msg, _callback, _errback)
    end,

    -- 帮派建立
    create = function ( param )
        local _callback = param.callback
        local msg = {
            m = "union",
            a = "createUnion",
            type = param.type,
            name = param.name
        }
        request(msg, _callback)
    end,

    -- 帮派排行榜
    rank = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "showUnionRank"
        }
        request(msg, _callback)
    end,

    -- 帮派搜索
    search = function ( param )
        local _callback = param.callback
        local msg = {
            m = "union",
            a = "searcheUnion",
            unionName = param.unionName, 
            start = param.startIndex, 
            total = param.total 
        }
        request(msg, _callback)
    end,

    -- 帮派修改公告、宣言 
    modify = function ( param )
        local _callback = param.callback
        local msg = {
            m = "union",
            a = "updateUnionIndes",
            msg = param.text, 
            type = param.type 
        }
        request(msg, _callback)
    end,

    -- 禅让帮主 
    demise = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "abdication" 
        }
        request(msg, _callback, _errback)
    end,

    -- 帮主自荐  
    zijian = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "coverLeader", 
            leaderId = param.leaderId 
        }
        request(msg, _callback, _errback)
    end,

    -- 检测自荐时间是否到 
    updateUnionLeader = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "updateUnionLeader" 
        }
        request(msg, _callback)
    end,

    -- 帮派成员列表
    showAllMember = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "showAllMember" 
        }
        request(msg, _callback)
    end,

    -- 成员审核列表 
    showApplyList = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "showApplyList", 
            unionId = param.unionId 
        }
        request(msg, _callback)
    end,
    
    -- 同意/拒绝加入帮派
    handleApply = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "handleApply", 
            unionId = param.unionId, 
            applyRoleId = param.applyRoleId, 
            type = param.type 
        }
        request(msg, _callback, _errback)
    end,

    -- 一键拒绝
    refuseAll = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "refuseAll" 
        }
        request(msg, _callback, _errback)
    end,

    -- 踢出帮派  
    kcikRole = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "kcikRole", 
            appRoleId = param.appRoleId 
        }
        request(msg, _callback, _errback) 
    end,

    -- 任命/取消任命  
    setPosition = function ( param )
        local _callback = param.callback
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "setposition", 
            appRoleId = param.appRoleId, 
            jopType = param.jopType 
        }
        request(msg, _callback, _errback)
    end,

    -- 退出帮派  
    exitUnion = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "exitUnion", 
            uid = param.uid 
        }
        request(msg, _callback, _errback)
    end,

    -- 福利列表 
    enterWelfare = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "enterWelfare" 
        }
        request(msg, _callback)
    end,

    -- 领取福利
    getReward = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "getReward", 
            id = param.id 
        }
        request(msg, _callback, _errback)
    end,

    -- 开启福利活动
    openActivities = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "openActivities", 
            id = param.id 
        }
        request(msg, _callback, _errback)
    end,

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

    -- 帮派大殿
    enterMainBuilding = function( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "enterMainBuilding" 
        }
        request(msg, _callback)
    end,

    -- 捐献
    unionDonate = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "unionDonate", 
            unionid = param.unionid, 
            donatetype = param.donatetype  
        }
        request(msg, _callback, _errback)
    end,

    -- 建筑升级
    unionLevelUp = function ( param )
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "unionLevelUp", 
            unionId = param.unionid, 
            buildtype = param.buildtype  
        }
        request(msg, _callback, _errback)
    end,

    -- 帮派动态 
    showDynamicList = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "showDynamicList" 
        } 
        request(msg, _callback) 
    end,

    -- 帮派作坊 
    enterWorkShop = function ( param )
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "enterWorkShop" 
        } 
        request(msg, _callback) 
    end,

    -- 作坊生产 
    unionWorkShopProduct = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "unionWorkShopProduct", 
            unionid = param.unionid, 
            overtimeflag = param.workType, 
            worktype = param.workId   
        }
        request(msg, _callback, _errback)
    end, 

    -- 作坊 立即结束 
    unionWorkShopGetReward = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "unionWorkShopGetReward", 
            unionId = param.unionId  
        }
        request(msg, _callback, _errback)
    end, 

    -- 作坊时间校验
    checkWorkShopTime = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union",
            a = "checkWorkShopTime", 
            type = param.type, 
        }
        request(msg, _callback, _errback)
    end,

    -- 进入青龙堂
    bossHistory = function (param)
        local _callback = param.callback 
        local msg = {
            m = "union",
            a = "bossHistory", 
            unionId = param.unionId,  
        }
        request(msg, _callback) 
    end, 

    -- 开启青龙堂boss挑战 
    bossCreate = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossCreate", 
            unionId = param.unionId, 
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

    -- boss伤害排行 
    bossTop = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossTop", 
            unionId = param.unionId, 
        }
        request(msg, _callback, _errback)
    end, 

    -- boss鼓舞、复活 
    bossPay = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossPay", 
            unionId = param.unionId, 
            use = param.use         -- 1银币鼓舞/2元宝鼓舞/元宝复活
        }
        request(msg, _callback, _errback)
    end, 

    -- boss战斗过程 
    bossPve = function ( param ) 
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "bossPve", 
            unionId = param.unionId, 
        }
        request(msg, _callback, _errback)
    end, 

    -- 帮派商店 
    unionShopList = function (param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "unionShopList", 
            shopflag = param.shopflag, 
            unionId = param.unionId 
        }
        request(msg, _callback, _errback)
    end,

    -- 检测帮派商店刷新时间 
    checkUnionShopTime = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "checkUnionShopTime", 
        }
        request(msg, _callback, _errback)
    end, 

    -- 帮派商品兑换 
    exchangeGoods = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "exchangeGoods", 
            id = param.id, 
            count = param.count, 
            type = param.type
        }
        request(msg, _callback, _errback)
    end, 

    -- 进入帮派副本 
    enterUnionCopy = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "enterUnionCopy", 
            type = param.type
        }
        request(msg, _callback, _errback)
    end, 

    -- 进入单个副本
    enterSingleCopy = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "enterSingleCopy", 
            type = param.type, 
            id = param.id 
        }
        request(msg, _callback, _errback)
    end, 

    -- 伤害排行 
    showHurtList = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "showHurtList" 
        }
        request(msg, _callback, _errback)
    end, 

    -- 领取帮派副本通关奖励 
    getFubenReward = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "receiveRewards", 
            type = param.type, 
            id = param.id  
        }
        request(msg, _callback, _errback)
    end, 

    -- 帮派副本挑选上阵侠客 
    chooseCard = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "chooseCard", 
        }
        request(msg, _callback, _errback)
    end, 

    -- 帮派副本战斗
    unionFBfight = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "union", 
            a = "unionFBfight", 
            type = param.type, 
            id = param.id, 
            fmt = param.fmt 
        }
        request(msg, _callback, _errback)
    end,  

}


-- 好友
RequestHelper.friend = {
    -- 获取好友列表  
    getFriendList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "getFriendList"
        }
        request(msg, _callback) 
    end, 



    --发送聊天
    sendChatContent = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "sendChatContent", 
            content = param.content,
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --更新对方聊天
    updateChatContent = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "updateChatContent", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --和好友断交
    removeFriend = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "removeFriend", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --推荐好友列表
    recommendList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "recommendList", 
            num = param.num,
            flag = param.flag
        }
        request(msg, _callback,param.errback) 
    end ,

    --邀请好友
    applyFriend = function(param)
        local _callback = param.callback 
        local _errback = param.errback 
        local msg = {
            m = "friend", 
            a = "applyFriend", 
            content = param.content,
            account = param.account
        }
        request(msg, _callback, _errback) 
    end ,

    --邀请好友
    searchFriend = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "searchFriend", 
            type = param.type,
            searchNum = param.searchNum,
            flag = param.flag,
            content= param.content
        }
        request(msg, _callback,param.errback) 
    end ,

    sendNaili = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "sendNaili", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end,

    --领取好友耐力丹
    getNaili = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "getNaili", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --领取全部好友耐力丹
    getNailiAll = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "getNailiAll"
        }
        request(msg, _callback,param.errback) 
    end ,

    --同意某人好友邀请
    acceptFriend = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "acceptFriend", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --驳回某人好友邀请
    rejectFriend = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "rejectFriend", 
            account = param.account
        }
        request(msg, _callback,param.errback) 
    end ,

    --同意所有好友
    acceptAll = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "acceptAll"
        }
        request(msg, _callback,param.errback) 
    end ,

    --拒绝所有好友
    --同意所有好友
    rejectAll = function(param)
        local _callback = param.callback 
        local msg = {
            m = "friend", 
            a = "rejectAll"
        }
        request(msg, _callback,param.errback) 
    end ,

}

-- 任务
RequestHelper.dialyTask = {
    
    --获取任务列表
    getTaskList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "mission", 
            a = "list"
        }
        request(msg, _callback,param.errback) 
    end ,

    --领取积分奖励
    getGift = function(param)
        local _callback = param.callback 
        local msg = {
            m = "mission", 
            a = "dailyReward",
            id = param.id
        }
        request(msg, _callback,param.errback) 
    end ,

    --领取任务奖励
    getTaskGift = function(param)
        local _callback = param.callback 
        local msg = {
            m = "mission", 
            a = "reward",
            id = param.id
        }
        request(msg, _callback,param.errback) 
    end ,

    checkBPSignIn = function(param)
        local _callback = param.callback 
        local msg = {
            m = "union", 
            a = "checkInUnion",
        }
        request(msg, _callback,param.errback) 
    end ,

}


-- 比武系统
RequestHelper.biwuSystem = {
    
    --获取基础信息
    getBaseInfo = function(param)
        local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "getInfo"
        }
        request(msg, _callback,param.errback) 
    end ,

    --刷新挑战英雄接口
    getRefreshHero = function(param)
        local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "refresh"
        }
        request(msg, _callback,param.errback) 
    end ,

    --获取仇人列表
    getEnemyList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "enemyList",
        }
        request(msg, _callback,param.errback) 
    end ,

    --获取兑换剩余次数劣币列表
    getExchangeList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "exchangeList"
        }
        request(msg, _callback,param.errback) 
    end ,

    --获取天榜列表
    getTianbangList = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "rankList"
        }
        request(msg, _callback,param.errback) 
    end ,
    --花费元宝购买挑战次数
    addChallengeTimes = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "buy",
            num = param.times
        }
        request(msg, _callback,param.errback) 
    end ,
    --兑换接口
    exChangeItem = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "exchange",
            itemId = param.id,
            num = param.num
        }
        request(msg, _callback,param.errback) 
    end ,
    --战斗接口
    getFightData = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "challenge",
            roleId = param.roleId,
            type = param.type
        }
        request(msg, _callback,param.errback) 
    end ,
    --战斗接口
    checkFight = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "check",
            roleId = param.roleId,
            type = param.type
        }
        request(msg, _callback,param.errback) 
    end 
    
}

-- 押镖系统
RequestHelper.yaBiaoSystem = {
    
    --获取基础信息
    getBaseInfo = function(param)
        local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "enterFace"
        }
        request(msg, _callback,param.errback) 
    end,
    --刷新其他镖车/全刷
    refreshAllEnemy = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "refreshOthers"
        }
        request(msg, _callback,param.errback) 
    end,
    --刷新其他镖车/补位 
    refreshSigleEnemy = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "repairOthers",
            repairIds = param.repairIds
        }
        request(msg, _callback,param.errback) 
    end,
    --镖车选择界面--状态
    carSelectState = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "choiceDart"
        }
        request(msg, _callback,param.errback) 
    end,
    --刷新镖车召唤镖车
    callNBCar = function (param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "refreshDart",
            tag = param.tag
        }
        request(msg, _callback,param.errback) 
    end,
    --镖车选择界面--选择
    carSelectOk = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "tournament", 
            a = "getInfo"
        }
        request(msg, _callback,param.errback) 
    end,
    --查看镖车信息
    getCarInfo = function (param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "dartData",
            roleID = param.roleID,
            dartkey = param.dartkey
        }
        request(msg, _callback,param.errback)
    end,
    --加速运镖
    beginRunWithSpeedUp = function (param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "speedUp"
        }
        request(msg, _callback,param.errback)
    end,
    --开始运镖
    beginRun = function (param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "start"
        }
        request(msg, _callback,param.errback)
    end,
    --抢镖
    forceGetCar = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "robDart",
            otherID = param.otherID,
            dartkey = param.dartkey
        }
        request(msg, _callback,param.errback)
    end,
    --押镖完成奖励领取
    getRewords = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "detainDart", 
            a = "acceptAward"
        }
        request(msg, _callback,param.errback)
    end
}


-- 限时兑换
RequestHelper.exchangeSystem = {
    --获取基础信息
    getExchangeList = function(param)
        local _callback = param.callback 
        local msg = {
            m = "exch", 
            a = "list"
        }
        request(msg, _callback,param.errback) 
    end,
    --奖励预览
    giftPreView = function(param)
        local _callback = param.callback 
        local msg = {
            m = "exch", 
            a = "award"
        }
        request(msg, _callback,param.errback) 
    end,
    --刷新
    refresh = function(param)
        local _callback = param.callback 
        local msg = {
            m = "exch", 
            a = "refresh",
            exchId = param.id
        }
        request(msg, _callback,param.errback) 
    end,
    --兑换
    exchange = function(param)
    	local _callback = param.callback 
        local msg = {
            m = "exch", 
            a = "exch",
            exchId = param.id
        }
        request(msg, _callback,param.errback) 
    end

}

-- 皇宫探宝
RequestHelper.tanbaoSystem = {
	--获取基础信息
    getBaseInfo = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "rouletteEnter"
        }
        request(msg, _callback,param.errback) 
    end,
	--预览物品
    preViewItem = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "roulettePreview",
            id = param.id
        }
        request(msg, _callback,param.errback) 
    end,
    --探宝
    startFind = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "rouletteOp",
            num = param.num
        }
        request(msg, _callback,param.errback) 
    end,
    --领取积分奖
    getReword = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "rouletteGetCredit",
            index = param.index
        }
        request(msg, _callback,param.errback) 
    end,
}

-- 迷宫寻宝
RequestHelper.wabaoSystem = {
	--获取基础信息
    getBaseInfo = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "mazeEnter"
        }
        request(msg, _callback,param.errback) 
    end,
	--刷新宝库
    refresh = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "mazeRefresh"
        }
        request(msg, _callback,param.errback) 
    end,
    --挖宝
    beginDig = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "mazeDig",
            type = param.type
        }
        request(msg, _callback,param.errback) 
    end,
}

-- 限时商店
RequestHelper.xianshiShopSystem = {
    --获取基础信息
    getBaseInfo = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "enterLimitShop"
        }
        request(msg, _callback,param.errback) 
    end,
    --领取
    getReword = function(param)
        local _callback = param.callback 
        local msg = {
            m = "activity", 
            a = "mazeRefresh"
        }
        request(msg, _callback,param.errback) 
    end
}



function RequestHelper.checkGold(param, url)
    local _callback = param.callback
    local msg = {
        m = "tx",
        a = "chengeGold",
        serverId = tostring(game.player.m_serverID),
        pfid = param.pfid,
        openid = param.openid,
        openkey = param.accesstoken,
        pay_token = param.pay_token,
        pf = param.pf,
        channelid = param.channelid,
        deviceid = param.deviceid,
        paymenttype = param.paymenttype,
        pfkey = param.pfkey,
    }
    printf(url)
    request(msg, _callback, nil, url)
end


-- 挑战副本 
RequestHelper.challengeFuben = {
    --副本详情 
    actDetail = function(param)
        local _callback = param.callback 
        local _errback = param.errback
        local msg = {
            m = "actbattle", 
            a = "actDetail", 
            aid = param.aid, 
            sysId = param.sysId, 
        }
        request(msg, _callback, _errback) 
    end,

    -- 保存阵型
    save = function(param)
        local _callback = param.callback 
        local _errback = param.errback
        local msg = {
            m = "actbattle", 
            a = "save", 
            aid = param.aid, 
            fmt = param.fmt, 
            sysId = param.sysId, 
        }
        request(msg, _callback, _errback) 
    end,

    -- 活动副本战斗
    actPve = function(param)
        local _callback = param.callback 
        local _errback = param.errback
        local msg = {
            m = "actbattle", 
            a = "actPve", 
            aid = param.aid, 
            sysId = param.sysId, 
            npc = param.npc, 
            npcLv = param.npcLv, 
            fmt = param.fmt 
        }
        request(msg, _callback, _errback) 
    end,
}




return RequestHelper

