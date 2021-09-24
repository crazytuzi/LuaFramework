local activity = {
    --情人节
    UM14021301 = {
        name        = '情人节-长相厮守我们天天在一起' ,
        type        = 1 ,
        begin_ts    = 1392307200 ,
        end_ts      = 1392566400 ,
        reward     = {props={{id=19,num=1}},gems=0} , --荣誉勋章
        status      = 1 ,
    },
    --元宵节
    UM14021302 = {
        name        = '元宵节-共赏月关卡资源送经验' ,
        type        = 2 ,
        begin_ts    = 1392307200 ,
        end_ts      = 1392566400 ,
        reward     = {} ,
        status      = 1 ,
        zoneid = {z11=1},
    },
    --循环送礼
    UM14021303 = {
        name        = '循环送礼送不停' ,
        type        = 3 ,
        begin_ts    = 1392307200 ,
        end_ts      = 1392566400 ,
        conditions  = {},
        reward     = {props={{id=47,num=1}},gems=0} , --幸运币
        status      = 1 ,
    },
}

return activity
