
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
            params = {"hbweng","hero_hebiweng","0","250","0.11","clip_1","20"},},
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




    {
        load = {tmpl = "mod21",
            params = {"jlfwang","hero_jinlunfawang","700","-220","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"deba","hero_daerba","560","-240","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"hdu","hero_huodu","820","-230","0.16","clip_1","90"},},
    },



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
            params = {"ydtian","hero_yangdingtian","-1050","-220","0.16","clip_1","90"},},
    },


    {   model = {
            tag  = "zslwang1",     type  = DEF.FIGURE,
            pos= cc.p(-860,-220),    order     = 90,
            file = "hero_zishanlongwang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.3,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zslwang2",     type  = DEF.FIGURE,
            pos= cc.p(-910,-225),    order     = 95,
            file = "hero_zishanlongwang",    animation = "yun",
            scale = 0.142,   parent = "clip_1", speed = 0.05,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},




    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-320,10),    order     = 45,
            file = "_lead_",    animation = "soushang",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},



    {
        load = {tmpl = "mod21",
            params = {"lmchou","hero_limochou","500","0","0.15","clip_1","50"},},
    },





    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},





     {
         load = {tmpl = "jt",
             params = {"clip_1","0","0.7","70","0"},},
     },


	{
        music = {file = "jq_bgm4.mp3",},
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
        delay = {time = 0.1,},
    },


     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_1","0.5","1","280","50"},},
     -- },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.6","0.7","-160","0"},},
     },
    {
        delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jttb",
             params = {"clip_1","2.5","0.7","200","0"},},
     },



    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(500,0),    order     = 45,
            file = "hero_limochou",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.7, rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "lmchou",sync = true,what = {move = {
                   time = 2,by = cc.p(-500,0),},},},},

    {remove = { model = {"lmchou", }, },},
    {
        load = {tmpl = "mod21",
            params = {"lmchou","hero_limochou","0","0","0.15","clip_1","45"},},
    },




    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"lmc","lmc.png",TR("李莫愁")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lmc",TR("臭小子，没那本事还想英雄救美！"),243},},
     },
     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("李莫愁！我进这江湖，为的就是行侠仗义！"),59},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("路见不平，却畏首畏尾，那还闯什么江湖！"),60},},
     },

     {
         load = {tmpl = "talk1",
             params = {"lmc",TR("哼！闯荡江湖？行侠仗义？真是可笑！你也不看看自己！像你这种废物——"),224},},
     },

     {
         load = {tmpl = "talk2",
             params = {"lmc",TR("还是死了的好！可惜！你就算是死了，也不会有人为你伤心的……"),225},},
     },



    {
        load = {tmpl = "out3",
            params = {"zj","lmc"},},
    },

    -- {
    --     model = { tag = "lhui",type  = DEF.PIC,
    --               file  = "nvzhu.png",order = 100,scale=1.2,
    --               pos   = cc.p(-600, 50),parent = "clip_1",rotation3D=cc.vec3(0,0,0),},
    -- },

    {remove = { model = {"text-board", }, },},


    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","-960","0","0.15","clip_1","50"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.7","670","-300"},},
     },

    {
        delay = {time = 0.5,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.4","3","2880","-640"},},
     },




    {
        music = {file = "jq_jy1.mp3",},
    },




     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.4","6","5760","-1060"},},
     },


    {
        delay = {time = 0.2,},
    },

        {
         model = {
            tag  ="clip2",      type   = DEF.CLIPPING,     order     = 100,
            file = "zhezhao0004.png",   scale    = 0.8,      pos= cc.p(480,600),},},

    -- {   model = {
    --         tag  = "qieping11",     type  = DEF.FIGURE,
    --         pos= cc.p(-200,0),    order     = -50,
    --         file = "effect_tongyisuduxian",    animation = "xia",
    --         scale = 2,    parent = "clip2",
    --         loop = false,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,0),
    --     },},



    {   model = {
            tag  = "qieping1",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 50,
            file = "effect_tongyiqieping_nan",    animation = "di",
            scale = 2,    parent = "clip2",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "qieping1",sync = false,what = {move = {
                   time = 0.1,by = cc.p(300,0),},},},},

    {   model = {
            tag  = "qieping2",     type  = DEF.FIGURE,
            pos= cc.p(300,0),    order     = 60,
            file = "effect_tongyiqieping_nan",    animation = "renwu_xia",
            scale = 2,    parent = "clip2",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "qieping2",sync = false,what = {move = {
                   time = 0.1,by = cc.p(-300,0),},},},},

    {
        delay = {time = 0.1,},
    },

    {
        model = { tag = "lhui",type  = DEF.PIC,
                  file  = "nvzhu.png",order = 70,scale=3.7,
                  pos   = cc.p(-800, -1000),parent = "clip2",rotation3D=cc.vec3(0,180,0),},
    },

        {action = { tag  = "lhui",sync = true,what = {move = {
                   time = 0.1,by = cc.p(240,210),},},},},

    {
        delay = {time = 0.4,},
    },

        {action = {tag  = "clip2", sync = false,
                what = {fadeout = {time = 1,},},},},



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","3","2880","-560"},},
     },

    -- {
    --     delay = {time = 0.2,},
    -- },


    -- {
    --     model = {
    --         tag = "heihua",
    --         speed = 0.5,
    --     },
    -- },


    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},






    -- {action = {tag  = "heihua", sync = true,what = {fadein = {time = 0,},},},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","1.2","1152","-320"},},
     },


    {remove = { model = {"clip2", }, },},



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("说——得好！谁——会——为一个笨蛋——伤心呢！"),226},},
     },

     {
         load = {tmpl = "move2",
             params = {"lmc","lmc.png",TR("李莫愁")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lmc",TR("你！？"),227},},
     },
    {
        load = {tmpl = "out3",
            params = {"lby","lmc"},},
    },


    {remove = { model = {"text-board", }, },},


    -- {   model = {
    --         tag  = "heimu1",     type  = DEF.FIGURE,
    --         pos= cc.p(320,560),    order     = 79,
    --         file = "effect_tongyisuduxian",    animation = "xia",
    --         scale = 1,
    --         loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
    --     },},
    {   model = {
            tag  = "heihua",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 6,    parent = "lbyi", opacity=255,
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.5,},
    },

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


    {   model = {
            tag  = "lbyi1",     type  = DEF.FIGURE,
            pos= cc.p(320,280),    order     = 82,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.08,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.3,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "lbyi1",sync = true,what ={ spawn={{scale= {time = 0.6,to = 0.08,},},
    {bezier = {time = 0.6,to = cc.p(320,780),
                                 control={cc.p(320,280),cc.p(320,380),}
    },},},
    },},},

    {remove = { model = {"lbyi1", }, },},

    {   model = {
            tag  = "lbyi1",     type  = DEF.FIGURE,
            pos= cc.p(320,780),    order     = 82,
            file = "effect_lihui_nvzhu",    animation = "animation",
            scale = 0.08,
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "skill_hanbingzhang.mp3",sync=false,},
    },

    {action = {tag  = "lbyi1",sync = true,what ={ spawn={{scale= {time = 0.9,to = 0.96,},},
    {bezier = {time = 0.9,to = cc.p(400,560),
                                 control={cc.p(0,580),cc.p(240,180),}
    },},},
    },},},


    {remove = { model = {"lbyi", }, },},
    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(-960,300),    order     = 50,
            file = "hero_nvzhu",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,40),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.6","376","-320"},},
     },
    {
        delay = {time = 0.15,},
    },
    {remove = { model = {"lbyi1", "heimu","mapbj1",}, },},

    {
        sound = {file = "hero_nvzhu_nuji.mp3",sync=false,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","0.8","86","-280"},},
     },
    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},

    {action = {tag  = "lbyi",sync = false,what ={ spawn={{rotate= {time = 0.6,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.6,to = cc.p(-200,0),
                                 control={cc.p(-960,300),cc.p(-600,600),}
    },},},
    },},},

    {
        delay = {time = 0.4,},
    },


    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 45,
            file = "hero_limochou",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "lmchou",sync = true,what = {move = {
                   time = 0.4,by = cc.p(150,0),},},},},

    {remove = { model = {"lmchou", }, },},



        {
         model = {
            tag  ="clip2",      type   = DEF.CLIPPING,     order     = 100,
            file = "bj.png",   scale    = 0.8,      pos= cc.p(480,420),},},





    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(20,-40),    order     = 45,
            file = "hero_limochou",    animation = "aida",
            scale = 0.15,   parent = "clip2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        delay = {time = 0.1,},
    },

    {
        model = {
            tag = "lmchou",
            speed = 0.1,
        },
    },

    {action = {tag  = "lmchou",sync = false,what ={ spawn={{rotate= {time = 1.8,to  = cc.vec3(0,180,60),},},},
    },},},

    -- {
    --     delay = {time = 20.4,},
    -- },



     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.8","0.8","-700","0"},},
     },

    {action = {tag  = "clip2",sync = true,what ={ spawn={{rotate= {time = 0.2,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.2,to = cc.p(560,640),
                                 control={cc.p(480,420),cc.p(520,600),}
    },},},
    },},},

    {action = {tag  = "clip2",sync = false,what ={ spawn={{rotate= {time = 3.2,to  = cc.vec3(0,0,-30),},},
    {bezier = {time = 3,to = cc.p(860,900),
                                 control={cc.p(560,640),cc.p(700,900),}
    },},},
    },},},


    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },


    {remove = { model = {"lbyi", }, },},
    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(-200,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},





    {action = {tag  = "lbyi",sync = false,what ={ spawn={{rotate= {time = 0.6,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 1.2,to = cc.p(700,400),control={cc.p(-200,0),cc.p(300,360),}
    },},},},},},






    {   model = {
            tag  = "shouji",     type  = DEF.FIGURE,
            pos= cc.p(20,0),    order     = 80,
            file = "effect_buff_fanji",    animation = "animation",
            scale = 0.7,     parent = "clip2",
            loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,-30),
        },},

    {   model = {
            tag  = "baozha1",     type  = DEF.FIGURE,
            pos= cc.p(20,0),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,     parent = "clip2",
            loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,-105),
        },},
    {   model = {
            tag  = "baozha2",     type  = DEF.FIGURE,
            pos= cc.p(20,0),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,    parent = "clip2",
            loop = true,   endRlease = true,  speed=1.5, rotation3D=cc.vec3(0,0,-120),
        },},

    {   model = {
            tag  = "baozha3",     type  = DEF.FIGURE,
            pos= cc.p(20,0),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,  parent = "clip2",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,-135),
        },},
    {   model = {
            tag  = "baozha4",     type  = DEF.FIGURE,
            pos= cc.p(20,0),    order     = 80,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 0.4,  parent = "clip2",
            loop = true,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,-150),
        },},

    {
        delay = {time = 0.1,},
    },

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },


    {   model = {
            tag  = "lbyi1",     type  = DEF.FIGURE,
            pos= cc.p(-200,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",  opacity=150,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},



    {action = {tag  = "lbyi1",sync = false,what ={ spawn={{rotate= {time = 0.6,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 1.2,to = cc.p(700,400),control={cc.p(-200,0),cc.p(300,360),}
    },},},},},},
    {
        delay = {time = 0.1,},
    },

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "lbyi3",     type  = DEF.FIGURE,
            pos= cc.p(-200,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1", opacity=100,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},


    {action = {tag  = "lbyi3",sync = false,what ={ spawn={{rotate= {time = 0.6,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 1.2,to = cc.p(700,400),control={cc.p(-200,0),cc.p(300,360),}
    },},},},},},

   {
        delay = {time = 0.1,},
    },
	
    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },	
	
	
    {   model = {
            tag  = "lbyi5",     type  = DEF.FIGURE,
            pos= cc.p(-200,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1", opacity=50,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "lbyi5",sync = false,what ={ spawn={{rotate= {time = 0.6,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 1.2,to = cc.p(700,400),control={cc.p(-200,0),cc.p(300,360),}
    },},},},},},

    {
        delay = {time = 0.9,},
    },

     {
         load = {tmpl = "jttb",
             params = {"clip_1","1","0.8","-100","0"},},
     },

    {remove = { model = {"lbyi", }, },},


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(700,400),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,0,30),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "lbyi",sync = false,what ={ spawn={{rotate= {time = 0.3,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.5,to = cc.p(960,0),control={cc.p(700,400),cc.p(800,300),}
    },},},},},},

   {
        delay = {time = 0.1,},
    },
    {remove = { model = { "lbyi1",}, },},
   {
        delay = {time = 0.1,},
    },
    {remove = { model = {"lbyi3", }, },},
   {
        delay = {time = 0.1,},
    },
    {remove = { model = {"lbyi5", }, },},

   {
        delay = {time = 0.2,},
    },

    {remove = { model = {"clip2",}, },},
    {remove = { model = {"lbyi",}, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"lmchou",}, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(1460,0),    order     = 45,
            file = "hero_limochou",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,5),
        },},
   {
        delay = {time = 0.1,},
    },

    {
        model = {
            tag = "lmchou",
            speed = 0,
        },
    },

   {
        delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.6","0.8","-250","0"},},
     },
   {
        delay = {time = 0.25,},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.3","0.8","200","0"},},
     },


    {   model = {
            tag  = "heihua1",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 5,    parent = "lbyi", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "heihua1",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua2",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "heihua2",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua3",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua3",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua4",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua4",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua5",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua5",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua6",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua6",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua7",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua7",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},

   {
        delay = {time = 0.25,},
    },

    {   model = {
            tag  = "heihua8",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 60,
            file = "effect_buff_siwangshanghai",    animation = "animation",
            scale = 1,    parent = "heihua1", opacity=0,
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "heihua8",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.65,by = cc.p(0,0),},},
                 {fadein ={time = 0.1, },},
                 {move = {time = 0.25,by = cc.p(0,0),},},
                 {fadeout = {time = 1,},},},},},},},


     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_1","0.6","0.8","150","0"},},
     -- },

    -- {
    --     delay = {time = 0.3,},
    -- },

    --     {action = { tag  = "heihua1",sync = true,what = {scale = {
    --                time = 0.3,to = 7,},},},},

    {
        delay = {time = 0.6,},
    },



    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk1",
             params = {"lby",TR("那么——你——也去——"),228},},
     },



    {
        sound = {file = "renwu_fenjie.mp3",sync=false,},
    },

        {action = { tag  = "heihua1",sync = true,what = {scale = {
                   time = 0.01,to = 9,},},},},

    {
        delay = {time = 0.5,},
    },


     {
         load = {tmpl = "talk2",
             params = {"lby",TR("——死吧！"),229},},
     },


     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父——你这是——？"),61},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("…………"),230},},
     },


	{
        music = {file = "jq_bgm3.mp3",},
    },



    {
        load = {tmpl = "out3",
            params = {"lby","zj"},},
    },


    {remove = { model = {"lbyi",}, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        delay = {time = 0.5,},
    },

    {remove = { model = {"lbyi",}, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

   {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.4","0.8","-200","0"},},
     },


    {remove = { model = {"lmchou",}, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(1460,0),    order     = 45,
            file = "hero_limochou",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},
   {
        delay = {time = 0.1,},
    },

    {remove = { model = {"lmchou",}, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(1460,0),    order     = 45,
            file = "hero_limochou",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"lmchou",}, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(1460,0),    order     = 45,
            file = "hero_limochou",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    -- {action = {tag  = "lmchou",sync = false,what = {
    --              {move = {time = 0.5,by = cc.p(300,200),},},},},},
        {action = { tag  = "lmchou",sync = true,what = {move = {
                   time = 0.5,by = cc.p(360,260),},},},},

    {remove = { model = {"lmchou",}, },},
    -- {remove = { model = {"baozha1", }, },},


    {remove = { model = {"lbyi",}, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

   {
        delay = {time = 0.2,},
    },




    {remove = { model = {"lbyi",}, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},


        {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,0),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {delay={time=0.5},},

    {
        model = {
            tag = "lbyi",
            speed = 0,
        },
    },



    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

     {action = {
             tag  = "lbyi",sync = true,what = {
             spawn = {{move = {time = 0.2,by= cc.p(0, 105), },},},
            },},},


        {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(960,105),    order     = 50,
            file = "hero_nvzhu",    animation = "poss",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,10),
        },},

     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.2","0.8","1200","0"},},
     },

    {action = {tag  = "lbyi",sync = true,what ={ spawn={{scale= {time = 1,to = 0.15,},},
    {bezier = {time = 1,to = cc.p(-180,0),
                                 control={cc.p(960,105),cc.p(300,400),}
    },},},
    },},},

        {remove = { model = {"lbyi", }, },},


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(-180,0),    order   = 49,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("你——伤得重吗？"),231},},
     },



    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-320","0","0.15","clip_1","40"},},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("嘿嘿！不碍事的！谢谢师父出手相救！"),62},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("哼！下次看你还逞不逞能！"),232},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("都怪我学艺不精，害师父担心了！"),63},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("不长记性！跟我走吧，找个地方，我替你运功疗伤！"),233},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },


    {
        load = {tmpl = "mod21",
            params = {"lwshuang","hero_luwushuang","400","40","0.15","clip_1","45"},},
    },



     {
         load = {tmpl = "jt",
             params = {"clip_1","0.3","0.8","-320","0"},},
     },



     {
         load = {tmpl = "move2",
             params = {"lws","lws.png",TR("陆无双")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lws",TR("谢谢你们！！"),234},},
     },


    {
        load = {tmpl = "out2",
            params = {"lws"},},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.3","0.8","320","0"},},
     },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父！你稍等一下，我和陆姑娘说几句话！"),64},},
     },

    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },


    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.2","0.8","-320","0"},},
     },


    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-320,0),    order     = 40,
            file = "_run_",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "zjue",sync = true,what = {move = {
                   time = 1.8,by = cc.p(600,30),},},},},


    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","280","30","0.15","clip_1","40"},},
    },

        {remove = { model = {"lbyi", }, },},


    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(-180,0),    order   = 49,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("陆姑娘！你没事吧！"),65},},
     },

     {
         load = {tmpl = "move2",
             params = {"lws","lws.png",TR("陆无双")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lws",TR("我——我没事，只是一点小伤！多亏你们出手相助，不然我肯定难逃李莫愁的魔掌！"),235},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("那就不用客气了，你这人什么都好，可就是太爱惹是生非了。"),66},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("李莫愁心性恶毒，你以后可要更加小心！"),67},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("嗯！我会小心的！"),236},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("哦！对了，你的脚！我这里有个小办法，悄悄告诉你哦………"),68},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("………………"),237},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("嗯嗯——我知道了！！"),238},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("好了！陆姑娘，我要走了，你也要多多保重！希望再见的时候，你可不要再麻烦缠身！"),69},},
     },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("谢谢你！这世上对我好的人没有几个，我将来一定会报答你的！"),239},},
     },


    {
        load = {tmpl = "out3",
            params = {"zj","lws"},},
    },


     {
         load = {tmpl = "jttb",
             params = {"clip_1","0.4","0.8","200","0"},},
     },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(280,30),    order     = 40,
            file = "_run_",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "zjue",sync = true,what = {move = {
                   time = 1,by = cc.p(-300,-30),},},},},


    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","-20","0","0.15","clip_1","40"},},
    },


     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("你和她说的什么？"),240},},
     },

     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("咦！？师父，你想知道？"),70},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("你不想说就算了！"),241},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("师父面前，徒儿哪会有不想说的呢！就怕师父没有兴趣！"),71},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("其实是这样的，陆姑娘的跛脚是因为左脚比起右脚短了一些，所以我叫她找个鞋匠，把左脚的鞋底做厚一些……"),72},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("——你倒是有些小聪明！"),242},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("嘿嘿嘿！多谢师父夸奖！"),73},},
     },

    {
        load = {tmpl = "out3",
            params = {"lby","zj"},},
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
         load = {tmpl = "zm",
             params = {TR("一番生死危机之后，结果似乎皆大欢喜"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("然而，你不曾注意的是"),"840"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("你师父那只执剑的手，正微微颤抖"),"780"},},
     },


     {
         load = {tmpl = "zm",
             params = {TR("冰冷的双眸之中，潜藏着一丝忧惧"),"720"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("看着你因为陆无双安然无恙而欣喜的笑容"),"660"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("她将眼中的那一丝情绪埋得更深……"),"600"},},
     },


    {delay = {time = 3,},},
    {remove = { model = {"900", "840", "780","720", "660", "600", }, },},




    {
	   delay = {time = 0.1,},
	},
}
