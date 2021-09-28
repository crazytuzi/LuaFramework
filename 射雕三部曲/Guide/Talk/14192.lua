
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
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

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
            params = {"gfu","hero_guofu","320","-320","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"gplu","hero_guopolu","220","-320","0.16","clip_1","90"},},
    },






    {
        load = {tmpl = "modbj1",
            params = {"bj31","ll_15.png","0.7","-150","-280","95","clip_1","0","0","0"},},
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
            params = {"zcong","hero_zhucong","-350","-350","0.16","clip_1","90"},},
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
             params = {"clip_1","0","0.7","-100","-200"},},
     },


	{
        music = {file = "battle5.mp3",},
    },




    -- {
    --     delay = {time = 0.1,},
    -- },



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




    {
        load = {tmpl = "mod21",
            params = {"lbyi","hero_nvzhu","300","0","0.15","clip_1","45"},},
    },


    {
        load = {tmpl = "mod22",
            params = {"jlfwang","hero_jinlunfawang","0","0","0.15","clip_1","50"},},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情




    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-400,60),    order     = 90,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
        delay = {time = 0.15,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.7","-100","-200"},},
     },

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 55,
            file = "hero_jinlunfawang",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "hero_jinlunfawang_nuji.mp3",sync=false,},
    },
    {
        delay = {time = 0.5,},
    },

    {remove = { model = {"lbyi", }, },},
    {
        sound = {file = "hero_nvzhu_nuji.mp3",sync=false,},
    },
    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 50,
            file = "hero_nvzhu",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.8,},
    },



        -- {action = { tag  = "hdu",sync = false,what = {move = {
        --            time = 1.2,by = cc.p(400,0),},},},},




        -- {action = { tag  = "xlnv",sync = false,what = {move = {
        --            time = 1.2,by = cc.p(200,0),},},},},
    {
        delay = {time = 0.8,},
    },

        {action = { tag  = "jlfwang",sync = false,what = {move = {
                   time = 0.8,by = cc.p(-250,0),},},},},

        {action = { tag  = "lbyi",sync = true,what = {move = {
                   time = 0.8,by = cc.p(250,0),},},},},


    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-250,0),    order     = 55,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,0,0),
        },},


    {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(550,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-250,0),    order     = 55,
            file = "hero_jinlunfawang",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
        {action = { tag  = "jlfwang",sync = true,what = {move = {
                   time = 0.4,by = cc.p(250,250),},},},},

















     {
        model = {
            tag   = "mapbj1",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = 80,
            file  = "bj.png",
        },
    },



    {   model = {
            tag  = "heimu",     type  = DEF.FIGURE,
            pos= cc.p(320,560),    order     = 81,
            file = "effect_nujifenwei",    animation = "animation",
            scale = 0.96,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


     {
        model = {
            tag   = "jl",
            type  = DEF.PIC,
            scale = 0.01,
            pos   = cc.p(320, 280),
            order = 80,
            file  = "zdlh_12422a.png",
        },
    },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "jl",sync = true,what ={ spawn={{scale= {time = 0.6,to = 0.4,},},
    {bezier = {time = 0.6,to = cc.p(320,560),
                                 control={cc.p(320,280),cc.p(320,380),}
    },},},
    },},},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.7","-100","-200"},},
     },
    {
        delay = {time = 0.25,},
    },

    {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.75, rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_jinlunfawang",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.25, rotation3D=cc.vec3(0,0,0),
        },},





    {
        delay = {time = 0.1,},
    },

    {remove = { model = {"jl", "heimu","mapbj1",}, },},


    {   model = {
            tag  = "lbyi1",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 55,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15, opacity=225, parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "lbyi2",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 55,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15, opacity=225, parent = "clip_1",
            loop = true,   endRlease = true,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "lbyi3",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 55,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15, opacity=225, parent = "clip_1",
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },
    {
        delay = {time = 0.3,},
    },
        {action = { tag  = "lbyi1",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-30,80),},},},},

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },
   {
        delay = {time = 0.3,},
    },

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },




        {action = { tag  = "lbyi2",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-30,-80),},},},},

    {
        delay = {time = 0.4,},
    },



        {action = { tag  = "lbyi1",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-800,-160),},},},},

    {
        delay = {time = 0.15,},
    },


    {   model = {
            tag  = "shouji",     type  = DEF.FIGURE,
            pos= cc.p(-120,80),    order     = 80,
            file = "effect_buff_fanji",    animation = "animation",
            scale = 0.7,     parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,-30),
        },},

    {   model = {
            tag  = "baozha1",     type  = DEF.FIGURE,
            pos= cc.p(-120,80),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,     parent = "clip_1",
            loop = true,   endRlease = true,  speed=1.5, rotation3D=cc.vec3(0,0,-30),
        },},
    {   model = {
            tag  = "baozha2",     type  = DEF.FIGURE,
            pos= cc.p(-120,80),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,    parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,-90),
        },},

    {   model = {
            tag  = "baozha4",     type  = DEF.FIGURE,
            pos= cc.p(-120,80),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,  parent = "clip_1",
            loop = true,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,-120),
        },},

    {
        delay = {time = 0.15,},
    },

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_jinlunfawang",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2.1, rotation3D=cc.vec3(0,0,0),
        },},




        {action = { tag  = "lbyi3",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-800,-60),},},},},


    {
        delay = {time = 0.3,},
    },
        {action = { tag  = "lbyi1",sync = false,what = {fadeout = {
                   time = 2,},},},},
        {action = { tag  = "lbyi2",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-800,80),},},},},

    {
        delay = {time = 0.5,},
    },

    {remove = { model = {"shouji", "baozha1","baozha2","baozha4","jlfwang","lbyi",}, },},

    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.75, rotation3D=cc.vec3(0,180,0),
        },},


    {remove = { model = {"lbyi1", "lbyi2","lbyi3",}, },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-200,-150),
                                 control={cc.p(-350,320),cc.p(-240,300),}
    },},},
    },},},
    {
        delay = {time = 0.3,},
    },


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.7","50","-200"},},
     },




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
             params = {"jlfw",TR("哼！本国师还要去参加英雄大会，不能与你们多做纠葛，告辞！"),"1197.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"jlfw"},},
    },


    {remove = { model = {"jlfwang",}, },},

    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.2,},
    },








    {remove = { model = {"jlfwang",}, },},

    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_jinlunfawang",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "jlfwang",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(-600,0),
                                 control={cc.p(-160,420),cc.p(-520,500),}
    },},},
    },},},

    {remove = { model = {"jlfwang",}, },},

    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("(哇靠，想不到这金轮法王在我美女师父面前也就是只肉鸡啊！)"),"1198.mp3"},},
     },




     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.7","100","-200"},},
     },

    {remove = { model = {"lbyi",}, },},


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.75, rotation3D=cc.vec3(0,180,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "lbyi",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.15,},},
    {bezier = {time = 0.2,to = cc.p(0,-150),
                                 control={cc.p(250,320),cc.p(50,300),}
    },},},
    },},},

    {remove = { model = {"zjue",}, },},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-200,-150),    order     = 60,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.3,},
    },



    {remove = { model = {"zjue",}, },},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-200,-150),    order     = 60,
            file = "_lead_",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},
    {
        delay = {time = 0.3,},
    },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("咦！？小龙女呢？"),"1199.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("你——你这个笨蛋！"),"1200.mp3"},},
     },
    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },







    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 2,by = cc.p(-400,0),},},},},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.5","0.9","2000","-200"},},
     },

    {
        delay = {time = 2,},
    },


       {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-2200,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,180,0),
        },},





     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"xln",TR("英雄大会？"),"1201.mp3"},},
     },

     {
         load = {tmpl = "talk0",
             params = {"xln",TR("过儿，喜欢热闹，不知道他会不会去参加这个英雄大会！"),"1202.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"xln",TR("不知……过儿，可还记得我这个姑姑？"),"1203.mp3"},},
     },


    {
        load = {tmpl = "out2",
            params = {"xln"},},
    },


    {
       delay = {time = 0.1,},
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
