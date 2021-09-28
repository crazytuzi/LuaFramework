
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 28, text = "@1",
            -- maxWidth = 600,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =0.4,
        },},
    {delay = {time = 0.8,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },


jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放

        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},

    },


qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },

    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1920, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj11","ll_22.png","1","-500","300","30","clip_1","0","-210","0"},},
    },
    {
        load = {tmpl = "modbj2",
            params = {"bj12","ui_effect_suanming","0.8","-480","280","28","clip_1","0","-180","0","0.5"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ybhui","hero_yangbuhui","-590","270","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"wxwen","hero_wuxiuwen","-650","250","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"hsnv","hero_huangshannv","-480","430","0.04","clip_1","20"},},
    },





    {
        load = {tmpl = "modbj2",
            params = {"bj141","ui_effect_xiaonvwawa","1.2","-540","360","48","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"hbweng","hero_huqingniu","0","260","0.115","clip_1","20"},},
    },


    {
        load = {tmpl = "mod21",
            params = {"nmxing","hero_nimoxing","400","280","0.10","clip_1","20"},},
    },







    {
        load = {tmpl = "modbj1",
            params = {"bj21","ll_23.png","0.8","670","350","15","clip_1","0","0","0"},},
    },
    {
        load = {tmpl = "modbj2",
            params = {"bj22","ui_effect_datiege","0.8","480","380","10","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj211","ll_22.png","1","620","300","30","clip_1","0","-210","0"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"zzliu","hero_zhuziliu","620","280","0.1","clip_1","20"},},
    },





    -- {
    --     load = {tmpl = "mod21",
    --         params = {"hdu","hero_huodu","820","-230","0.16","clip_1","90"},},
    -- },



    {
        load = {tmpl = "modbj1",
            params = {"bj1041","ll_14.png","0.6","1150","-180","95","clip_1","0","0","0"},},
    },
    {
        load = {tmpl = "modbj1",
            params = {"bj10411","ll_14.png","0.7","0","70","-95","bj1041","0","0","0"},},
    },
    {
        load = {tmpl = "modbj1",
            params = {"bj1042","ll_21.png","0.7","0","150","500","bj1041","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj1037","ui_effect_hejiu","1","150","-10","48","bj1041","0","0","0","0.5"},},
    },



    {
        load = {tmpl = "mod21",
            params = {"gfu","hero_guofu","320","-240","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"gplu","hero_guopolu","220","-240","0.16","clip_1","90"},},
    },






    {
        load = {tmpl = "modbj1",
            params = {"bj31","ll_15.png","0.7","-150","-180","95","clip_1","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj35","ui_effect_chifan_a","1","50","360","98","bj31","0","0","0","1"},},
    },

    -- {
    --     load = {tmpl = "modbj2",
    --         params = {"bj37","ui_effect_hejiu","1","-150","0","48","bj31","0","0","0","1"},},
    -- },

    {
        load = {tmpl = "modbj2",
            params = {"bj36","ui_effect_chifan_b","1","100","400","-94","bj31","0","0","0","1"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj32","ll_16.png","1","20","-310","-80","bj35","0","0","0"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj33","ll_17.png","1","150","-270","-93","bj36","0","0","0"},},
    },




    {
        load = {tmpl = "modbj1",
            params = {"bj41","ll_14.png","0.6","-550","-180","95","clip_1","0","0","0"},},
    },
    {
        load = {tmpl = "modbj1",
            params = {"bj411","ll_14.png","0.7","0","70","-95","bj41","0","0","0"},},
    },
	{
        load = {tmpl = "modbj1",
            params = {"bj42","ll_21.png","0.7","0","150","500","bj41","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj37","ui_effect_hejiu","1","150","-10","48","bj41","0","0","0","0.5"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"zcong","hero_zhucong","-350","-270","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lyjiao","hero_luyoujiao","-700","-230","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ydtian","hero_yangdingtian","-1050","200","0.14","clip_1","40"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"zasheng","hero_zhangasheng","-1150","180","0.14","clip_1","40"},},
    },



    {   model = {
            tag  = "zslwang1",     type  = DEF.FIGURE,
            pos= cc.p(-860,200),    order     = 40,
            file = "hero_zishanlongwang",    animation = "daiji",
            scale = 0.13,   parent = "clip_1", speed = 0.3,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zslwang2",     type  = DEF.FIGURE,
            pos= cc.p(-910,195),    order     = 45,
            file = "hero_zishanlongwang",    animation = "yun",
            scale = 0.122,   parent = "clip_1", speed = 0.05,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},




    -- {   model = {
    --         tag  = "zjue",     type  = DEF.FIGURE,
    --         pos= cc.p(-320,10),    order     = 45,
    --         file = "_lead_",    animation = "soushang",
    --         scale = 0.14,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
    --     },},




    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},





     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","800","-200"},},
     },


	{
        music = {file = "backgroundmusic6.mp3",},
    },


    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情





    {
        delay = {time = 1,},
    },
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "shunvzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","0.8","1400","-200"},},
     },



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿，你现在在哪里？有没有想过我呢？"),"1168.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"xln"},},
    },

       {remove = { model = {"text-board", }, },},





       {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 2,by = cc.p(400,0),},},},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","2","0.8","1000","-200"},},
     },


    {
        delay = {time = 1.2,},
    },

    {remove = { model = {"ydtian", }, },},


    {
        load = {tmpl = "mod21",
            params = {"ydtian","hero_yangdingtian","-1050","200","0.14","clip_1","40"},},
    },
    {remove = { model = {"zasheng", }, },},
    {
        load = {tmpl = "mod21",
            params = {"zasheng","hero_zhangasheng","-1150","180","0.14","clip_1","45"},},
    },

    {
        delay = {time = 0.6,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zasheng",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-1200,-50),
                                 control={cc.p(-1150,180),cc.p(-1160,400),}
    },},},
    },},},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "ydtian",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-1150,0),
                                 control={cc.p(-1050,200),cc.p(-1080,400),}
    },},},
    },},},

    {remove = { model = {"xlnv", }, },},


    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1400,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"zas","zas.png",TR("恶霸喽啰")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zas",TR("唉！小美人！一个人啊！要不要哥哥带你去一个很好玩的地方！"),"1169.mp3"},},
     },


     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你走开，我不想和你说话！"),"1170.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zas",TR("哟呵！小娘们！给你脸——你还不要是吧，那可别怪哥哥来硬的了！"),"1171.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"xln","zas"},},
    },


    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-1800,300),    order     = 55,
            file = "hero_huodu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "hero_huodu_pugong.mp3",sync=false,},
    },

    {
        delay = {time = 0.5,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "hdu",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.7,to = cc.p(-1100,0),
                                 control={cc.p(-1500,500),cc.p(-1300,100),}
    },},},
    },},},

    {
        delay = {time = 0.4,},
    },

        {action = { tag  = "zasheng",sync = false,what = {move = {
                   time = 0.2,by = cc.p(200,0),},},},},
        {action = { tag  = "ydtian",sync = false,what = {move = {
                   time = 0.2,by = cc.p(200,0),},},},},

    {
        delay = {time = 0.2,},
    },


    {action = {tag  = "zasheng",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-700,250),
                                 control={cc.p(-900,-50),cc.p(-800,-50),}
    },},},
    },},},

    {action = {tag  = "ydtian",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-650,300),
                                 control={cc.p(-850,0),cc.p(-750,0),}
    },},},
    },},},

    {
        delay = {time = 0.3,},
    },

    {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-1100,0),    order     = 55,
            file = "hero_huodu",    animation = "win",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},




    {remove = { model = {"ydtian", }, },},


    {remove = { model = {"zasheng", }, },},



     {
         load = {tmpl = "move1",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("哼！也不知道是谁不开眼，这等绝色美女，岂是你们这些愚夫俗子能够染指的！还不快滚！"),"1172.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"hd"},},
    },


    {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-1100,0),    order     = 55,
            file = "hero_huodu",    animation = "win",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},



     {
         load = {tmpl = "move2",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("这位姑娘！在下有礼了！小王乃是蒙古王子——霍都，师承蒙古国师金轮法王，敢问姑娘芳名？"),"1173.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你走开，我也不想和你说话！"),"1174.mp3"},},
     },


     {
         load = {tmpl = "talk1",
             params = {"hd",TR("你！哈哈哈！想这世间女子听了本王的名号，无不受宠若惊，倒是你，却是如此冷淡！"),"1175.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"hd",TR("不过，你勾起本王的兴致！哼哼~就别想逃过本王的手心！"),"1176.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"xln","hd"},},
    },


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1400,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 0.4,by = cc.p(50,100),},},},},

    {
        delay = {time = 0.2,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "hdu",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-1200,100),
                                 control={cc.p(-1100,0),cc.p(-1150,200),}
    },},},
    },},},
    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1350,100),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},




    {
        delay = {time = 0.4,},
    },




    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1350,100),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 0.4,by = cc.p(50,-100),},},},},

    {
        delay = {time = 0.2,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "hdu",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-1100,0),
                                 control={cc.p(-1200,100),cc.p(-1150,200),}
    },},},
    },},},


    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1300,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你要做什么？不要挡住我的路！"),"1177.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("想走？可以，不过，你得先陪小王喝一杯！"),"1178.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你再不让开，我可要动手了！"),"1179.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"hd",TR("哼哼哼~呆会儿你就知道本王的好了！"),"1178.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"xln","hd"},},
    },
       {remove = { model = {"text-board", }, },},




    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1300,0),    order     = 55,
            file = "hero_xiaolongnv",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "hero_xiaolongnv_nuji.mp3",sync=false,},
    },
    {
        delay = {time = 0.5,},
    },

    {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-1100,0),    order     = 50,
            file = "hero_huodu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.9, rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "hero_huodu_pugong.mp3",sync=false,},
    },
    {
        delay = {time = 0.2,},
    },


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.2","0.8","600","-200"},},
     },

        {action = { tag  = "hdu",sync = false,what = {move = {
                   time = 1.2,by = cc.p(400,0),},},},},

    {
        delay = {time = 0.2,},
    },


        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 1.2,by = cc.p(200,0),},},},},
    {
        delay = {time = 0.8,},
    },

    {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-700,0),    order     = 50,
            file = "hero_huodu",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.1,},
    },

        {action = { tag  = "hdu",sync = false,what = {move = {
                   time = 0.5,by = cc.p(250,0),},},},},

    {
        delay = {time = 0.7,},
    },

    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1100,0),    order     = 55,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,0,0),
        },},


    {
        delay = {time = 0.3,},
    },

    {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-400,0),    order     = 50,
            file = "hero_huodu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("小贱人！你竟然敢伤了本王！"),"1181.mp3"},},
     },


    {
        load = {tmpl = "out2",
            params = {"hd"},},
    },



    {
        load = {tmpl = "mod21",
            params = {"jlfwang","hero_jinlunfawang","100","220","0.11","clip_1","50"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"deba","hero_daerba","-60","220","0.11","clip_1","50"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-100","-200"},},
     },



     {
         load = {tmpl = "move1",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("师兄，快来帮帮我！"),"1182.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"hd"},},
    },




    {remove = { model = {"deba", }, },},

    {
        load = {tmpl = "mod21",
            params = {"deba","hero_daerba","-60","220","0.11","clip_1","45"},},
    },

    {
        delay = {time = 0.15,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "deba",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-400,100),
                                 control={cc.p(-60,220),cc.p(-160,500),}
    },},},
    },},},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","600","-200"},},
     },

    {
        delay = {time = 0.5,},
    },

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1100,20),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        load = {tmpl = "mod21",
            params = {"lcfeng","hero_luchengfeng","800","160","0.15","clip_1","45"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"bdhshang","hero_budaiheshang","990","-270","0.16","clip_1","60"},},
    },
    -- {   model = {
    --         tag  = "lbyi",     type  = DEF.FIGURE,
    --         pos= cc.p(1200,0),    order     = 45,
    --         file = "hero_nvzhu",    animation = "zou",
    --         scale = 0.15,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {
    --     delay = {time = 1.2,},
    -- },


    --     {action = { tag  = "lbyi",sync = true,what = {move = {
    --                time = 0.2,by = cc.p(40,0),},},},},

    -- {remove = { model = {"lbyi", }, },},

    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","1250","0","0.15","clip_1","45"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","1.2","0.8","-800","-200"},},
     },


     {
         load = {tmpl = "move2",
             params = {"lcf","lcf.png",TR("酸秀才")},},
     },

     {
         load = {tmpl = "talk",
             params = {"lcf",TR("那边有人打起来！是蒙古人在欺负我们汉人的女子！"),"1183.mp3"},},
     },


    {
        load = {tmpl = "out2",
            params = {"lcf"},},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("嗯！？蒙古人！？师父，我们……"),"1184.mp3"},},
     },




    {
        delay = {time = 0.1,},
    },

    {remove = { model = {"lbyi", }, },},

    {
        load = {tmpl = "mod21",
            params = {"lbyi","hero_nvzhu","1250","0","0.15","clip_1","45"},},
    },


     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("不许多事！现在最要紧的事——是找到小龙女！"),"1185.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父啊！好歹我们也是汉人啊，怎么能让蒙古番子骑到咱们头上来啊！"),"1186.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("你是不想听师父的话吗，我说了，除了小龙女，其它的事——都与我们无关！"),"1187.mp3"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("（师父什么都好，就是这性子——太淡漠了，以后得想想办法让师父改改这冰冷的性子！）"),"1188.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("哎呀，师父！这找小龙女，有如大海捞针，说不得那个被围攻的女子就是小龙女呢！"),"1189.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("嗯！？——那便去看看吧，如果不是小龙女，你可不许上次那样擅自动手！"),"1190.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("（嘿嘿，我的美女师父！这手可是长在我身上！顶多到时候再被罚一顿！）"),"1191.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },

       {remove = { model = {"text-board", }, },},


    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1100,20),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},



    {remove = { model = {"jlfwang", }, },},

    {
        load = {tmpl = "mod21",
            params = {"jlfwang","hero_jinlunfawang","0","220","0.11","clip_1","50"},},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.8","-100","-200"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(360,-60),
                                 control={cc.p(900,320),cc.p(500,240),}
    },},},
    },},},
    {
        delay = {time = 0.1,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "lbyi",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(360,120),
                                 control={cc.p(1050,300),cc.p(500,400),}
    },},},
    },},},

    {remove = { model = {"jlfwang", }, },},

    {
        load = {tmpl = "mod22",
            params = {"jlfwang","hero_jinlunfawang","0","220","0.11","clip_1","50"},},
    },

    {
        delay = {time = 0.1,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "jlfwang",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.14,},},
    {bezier = {time = 0.1,to = cc.p(150,100),
                                 control={cc.p(0,220),cc.p(50,500),}
    },},},
    },},},


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("中原武林，果然能人辈出，这般年轻的女子都能有如此功夫，让人不能小觑！"),"1195.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"jlfw"},},
    },


     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("我拦住他，你去帮小龙女。"),"11951.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("是，师父！"),"10201.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },

       {remove = { model = {"text-board", }, },},







     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","0.8","600","-200"},},
     },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.5,to = cc.p(-850,60),
                                 control={cc.p(160,420),cc.p(-650,440),}
    },},},
    },},},

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-850,60),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},




    {
       delay = {time = 0.3,},
    },


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
