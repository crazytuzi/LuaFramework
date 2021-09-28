
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

    zm0= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p("@1","@2"), order  = 105,
            size   = 28, text = "@3",
            maxWidth = 580,
			opacity=0,
            color  = cc.c3b(244, 217, 174),
            time   =0,
        },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 28, text = "@1",
            -- maxWidth = 640,
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
        music = {file = "battle1.mp3",},
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
            pos = cc.p(0,-300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0,0),
            order = -99,
            file  = "zongnanshan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920,0),
            order = -99,
            file  = "zongnanshan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1920,0),
            order = -99,
            file  = "zongnanshan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
     {
         load = {tmpl = "jt",
             params = {"clip_1","0","0.8","400","200"},},
     },



    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },








    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-1000,400),    order     = 45,
            file = "hero_guojing",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-1000,200),    order     = 45,
            file = "hero_huangrong",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "gjing",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-100,-100),
                                 control={cc.p(-1000,400),cc.p(-400,400),}
    },},},
    },},},

    {action = {tag  = "hrong",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-100,-300),
                                 control={cc.p(-1000,200),cc.p(-400,200),}
    },},},
    },},},


    {
       delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.6","0.8","-350","0"},},
     },


       {remove = { model = {"gjing", }, },},
       {remove = { model = {"hrong", }, },},




    {
        load = {tmpl = "mod22",
            params = {"gjing","hero_guojing","-100","-100","0.15","clip_1","50"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"hrong","hero_huangrong","-100","-300","0.15","clip_1","50"},},
    },

    {
       delay = {time = 0.3,},
    },

    {
        load = {tmpl = "mod21",
            params = {"oyke","hero_ouyangke","700","-100","0.15","clip_1","25"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"hdu","hero_huodu","900","-100","0.15","clip_1","25"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"fyao","hero_fanyao","750","100","0.15","clip_1","15"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"gszhi","hero_gongsunzhi","950","100","0.15","clip_1","15"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"qqren","hero_qiuqianren","750","-300","0.15","clip_1","50"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"nmxing","hero_nimoxing","950","-300","0.15","clip_1","51"},},
    },





     {
         load = {tmpl = "jt",
             params = {"clip_1","1.2","0.5","-250","0"},},
     },

    {
       delay = {time = 0.1,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("郭靖！我已经恭候多时了！"),83},},
     },
     {
         load = {tmpl = "move1",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("欧阳克，你也是为了传说中的武林秘宝而来？"),84},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("哼哼哼！——我叔叔已经上山夺取秘宝！而我——是来杀你的！"),85},},
     },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"gj",TR("就凭你——也想杀我？"),86},},
     -- },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"oyk",TR("就算你武功再厉害，这次，你也插翅难逃！"),87},},
     -- },

    {
        load = {tmpl = "out1",
            params = {"gj"},},
    },

     {
         load = {tmpl = "move1",
             params = {"hr","hr.png",TR("黄蓉")},},
     },

     {
         load = {tmpl = "talk",
             params = {"hr",TR("我还在纳闷——现在的拦路恶狗怎么这么猖狂？原来是有帮手啊！"),88},},
     },

     {
         load = {tmpl = "talk1",
             params = {"oyk",TR("黄蓉，任你尖牙俐齿，今天我便先杀了你身边的傻小子——"),89},},
     },

     {
         load = {tmpl = "talk2",
             params = {"oyk",TR("再把你掳到我白驼山庄，好好品尝你这张利嘴，到时——我看谁能救你！"),90},},
     },

    {
        load = {tmpl = "out3",
            params = {"hr","oyk"},},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "hdu",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(500,-100),
                                 control={cc.p(850,-50),cc.p(800,300),}
    },},},
    },},},

    {action = {tag  = "nmxing",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(500,-300),
                                 control={cc.p(1000,-250),cc.p(950,100),}
    },},},
    },},},

    {action = {tag  = "gszhi",sync = true,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(500,100),
                                 control={cc.p(950,150),cc.p(900,500),}
    },},},
    },},},

     -- {
     --     load = {tmpl = "move2",
     --         params = {"hd","hd.png","霍都"},},
     -- },
     -- {
     --     load = {tmpl = "talk",
     --         params = {"hd",TR("郭靖，你贱命一条死了也就死了，可惜了你身边的美人……"),91},},
     -- },

     {
         load = {tmpl = "move1",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("你们——谁也别想欺负我的蓉儿！"),92},},
     },
    {
        load = {tmpl = "out1",
            params = {"gj"},},
    },
    -- {
    --     load = {tmpl = "out3",
    --         params = {"gj","hd"},},
    -- },
       {remove = { model = {"text-board", }, },},




     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","-120","-100"},},
     },

       {remove = { model = {"gjing", }, },},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-100,-100),    order     = 45,
            file = "hero_guojing",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},


    {action = {tag  = "gjing",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(50,-100),
                                 control={cc.p(-100,-100),cc.p(0,-100),}
    },},},
    },},},

       {remove = { model = {"gjing", }, },},

    {
        load = {tmpl = "mod22",
            params = {"gjing","hero_guojing","50","-100","0.15","clip_1","50"},},
    },





    -- {   model = {
    --         tag  = "ykang1",     type  = DEF.FIGURE,
    --         pos= cc.p(570,-100),    order     = 50,
    --         file = "hero_huodu",    animation = "pugong",
    --         scale = 0.14,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
    --     },},

    --     -- {remove = { model = {"ykxi", }, },},

    -- {   model = {
    --         tag  = "ykxi1",     type  = DEF.FIGURE,
    --         pos= cc.p(520,-300),    order     = 50,
    --         file = "hero_nimoxing",    animation = "pugong",
    --         scale = 0.14,   parent = "clip_1",opacity=125,
    --         loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,0),
    --     },},



    --     -- {remove = { model = {"hbweng", }, },},
    -- {   model = {
    --         tag  = "hbweng1",     type  = DEF.FIGURE,
    --         pos= cc.p(530,100),    order     = 50,
    --         file = "hero_gongsunzhi",    animation = "pugong",
    --         scale = 0.14,   parent = "clip_1",opacity=125,
    --         loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,0),
    --     },},





     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","1.2","-100","0"},},
     },

       {remove = { model = {"gjing", }, },},


    {
        sound = {file = "hero_guojing_nuji.mp3",sync=false,},
    },
    {
        sound = {file = 93,sync=false,},
    },

    {   model = {
            tag  = "gjing1",     type  = DEF.FIGURE,
            pos= cc.p(120,-120),    order     = 45,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=125,
            loop = false,   endRlease = true,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "gjing2",     type  = DEF.FIGURE,
            pos= cc.p(120,-80),    order     = 45,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = true,  speed=1.62, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "gjing21",     type  = DEF.FIGURE,
            pos= cc.p(150,-100),    order     = 45,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=195,
            loop = false,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "long1",     type  = DEF.FIGURE,
            pos= cc.p(150,0),    order     = 30,
            file = "effect_wg_xianglongzhang",    animation = "animation",
            scale = 0.3,   parent = "clip_1", opacity=125,
            loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "long1",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.4,by = cc.p(0,0),},},
                 {fadeout = {time = 0.1,},},
                 {move = {time = 0.75,by = cc.p(0,0),},},
                 {fadein = {time = 0.183,},},},},},},},
    {action = {tag  = "long1",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.7,to = cc.p(150,0),
                                 control={cc.p(-100,200),cc.p(-100,-200),}
    },},},},
    },},},



    {
       delay = {time = 0.4,},
    },





    {   model = {
            tag  = "long2",     type  = DEF.FIGURE,
            pos= cc.p(50,0),    order     = 30,
            file = "effect_wg_xianglongzhang",    animation = "animation",
            scale = 0.3,   parent = "clip_1", opacity=125,
            loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "long2",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.4,by = cc.p(0,0),},},
                 {fadeout = {time = 0.1,},},
                 {move = {time = 0.75,by = cc.p(0,0),},},
                 {fadein = {time = 0.183,},},},},},},},

    {action = {tag  = "long2",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.7,to = cc.p(50,0),
                                 control={cc.p(-200,200),cc.p(-200,-200),}
    },},},},
    },},},


    {
        model = {
            tag = "gjing1",
            speed = 0,
        },
    },

    {
       delay = {time = 0.4,},
    },

    -- {   model = {
    --         tag  = "long3",     type  = DEF.FIGURE,
    --         pos= cc.p(150,-100),    order     = 30,
    --         file = "effect_wg_xianglongzhang",    animation = "animation",
    --         scale = 0.3,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,180,0),
    --     },},

    -- {action = {tag  = "long3",sync = false,what = {loop = {sequence = {
    --              {move = {time = 0.4,by = cc.p(0,0),},},
    --              {fadeout = {time = 0.1,},},
    --              {move = {time = 0.75,by = cc.p(0,0),},},
    --              {fadein = {time = 0.183,},},},},},},},
    -- {action = {tag  = "long3",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    -- {bezier = {time = 0.7,to = cc.p(150,-100),
    --                              control={cc.p(-100,100),cc.p(-100,-300),}
    -- },},},},
    -- },},},






    {
        model = {
            tag = "gjing2",
            speed = 0,
        },
    },

    {
       delay = {time = 0.4,},
    },

    -- {   model = {
    --         tag  = "long4",     type  = DEF.FIGURE,
    --         pos= cc.p(50,-100),    order     = 30,
    --         file = "effect_wg_xianglongzhang",    animation = "animation",
    --         scale = 0.3,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {action = {tag  = "long4",sync = false,what = {loop = {sequence = {
    --              {move = {time = 0.4,by = cc.p(0,0),},},
    --              {fadeout = {time = 0.1,},},
    --              {move = {time = 0.75,by = cc.p(0,0),},},
    --              {fadein = {time = 0.183,},},},},},},},

    -- {action = {tag  = "long4",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    -- {bezier = {time = 0.7,to = cc.p(50,-100),
    --                              control={cc.p(-200,100),cc.p(-200,-300),}
    -- },},},},
    -- },},},



    {
        model = {
            tag = "gjing21",
            speed = 0,
        },
    },

    {
       delay = {time = 0.5,},
    },

    {
        sound = {file = "hero_guojing_nuji.mp3",sync=false,},
    },


    {   model = {
            tag  = "gjing3",     type  = DEF.FIGURE,
            pos= cc.p(0,-120),    order     = 55,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",opacity=125,
            loop = false,   endRlease = true,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},
    {   model = {
            tag  = "gjing4",     type  = DEF.FIGURE,
            pos= cc.p(0,-80),    order     = 55,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = true,  speed=1.62, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "gjing41",     type  = DEF.FIGURE,
            pos= cc.p(-30,-100),    order     = 55,
            file = "hero_guojing",    animation = "nuji",
            scale = 0.15,   parent = "clip_1", opacity=195,
            loop = false,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "long5",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 30,
            file = "effect_wg_xianglongzhang",    animation = "animation",
            scale = 0.3,   parent = "clip_1", opacity=125,
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "long5",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.4,by = cc.p(0,0),},},
                 {fadeout = {time = 0.1,},},
                 {move = {time = 0.75,by = cc.p(0,0),},},
                 {fadein = {time = 0.183,},},},},},},},
    {action = {tag  = "long5",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.7,to = cc.p(0,0),
                                 control={cc.p(-250,200),cc.p(-250,-200),}
    },},},},
    },},},


    {
       delay = {time = 0.4,},
    },

    {   model = {
            tag  = "long6",     type  = DEF.FIGURE,
            pos= cc.p(-150,0),    order     = 30,
            file = "effect_wg_xianglongzhang",    animation = "animation",
            scale = 0.3,   parent = "clip_1", opacity=125,
            loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "long6",sync = false,what = {loop = {sequence = {
                 {move = {time = 0.4,by = cc.p(0,0),},},
                 {fadeout = {time = 0.1,},},
                 {move = {time = 0.75,by = cc.p(0,0),},},
                 {fadein = {time = 0.183,},},},},},},},

    {action = {tag  = "long6",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.7,to = cc.p(-100,0),
                                 control={cc.p(-350,200),cc.p(-350,-200),}
    },},},},
    },},},

    {
        model = {
            tag = "gjing3",
            speed = 0,
        },
    },


    {
       delay = {time = 0.4,},
    },
    -- {   model = {
    --         tag  = "long51",     type  = DEF.FIGURE,
    --         pos= cc.p(0,-100),    order     = 30,
    --         file = "effect_wg_xianglongzhang",    animation = "animation",
    --         scale = 0.3,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,180,0),
    --     },},
    -- {action = {tag  = "long51",sync = false,what = {loop = {sequence = {
    --              {move = {time = 0.4,by = cc.p(0,0),},},
    --              {fadeout = {time = 0.1,},},
    --              {move = {time = 0.75,by = cc.p(0,0),},},
    --              {fadein = {time = 0.183,},},},},},},},
    -- {action = {tag  = "long51",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    -- {bezier = {time = 0.7,to = cc.p(0,-100),
    --                              control={cc.p(-250,100),cc.p(-250,-300),}
    -- },},},},
    -- },},},

    {
        model = {
            tag = "gjing4",
            speed = 0,
        },
    },


    {
       delay = {time = 0.4,},
    },


    -- {   model = {
    --         tag  = "long61",     type  = DEF.FIGURE,
    --         pos= cc.p(-150,-100),    order     = 30,
    --         file = "effect_wg_xianglongzhang",    animation = "animation",
    --         scale = 0.3,   parent = "clip_1", opacity=125,
    --         loop = true,   endRlease = true,  speed=2, rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {action = {tag  = "long61",sync = false,what = {loop = {sequence = {
    --              {move = {time = 0.4,by = cc.p(0,0),},},
    --              {fadeout = {time = 0.1,},},
    --              {move = {time = 0.75,by = cc.p(0,0),},},
    --              {fadein = {time = 0.183,},},},},},},},

    -- {action = {tag  = "long61",sync = false,what ={loop = { spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    -- {bezier = {time = 0.7,to = cc.p(-100,-100),
    --                              control={cc.p(-350,100),cc.p(-350,-300),}
    -- },},},},
    -- },},},


    {
        model = {
            tag = "gjing41",
            speed = 0,
        },
    },








    {
       delay = {time = 0.5,},
    },


    -- {   model = {
    --         tag  = "gjing4",     type  = DEF.FIGURE,
    --         pos= cc.p(60,-100),    order     = 45,
    --         file = "hero_guojing",    animation = "nuji",
    --         scale = 0.15,   parent = "clip_1",opacity=200,
    --         loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
    --     },},

    -- {
    --    delay = {time = 0.4,},
    -- },




    {
        model = {
            tag = "gjing3",
            speed = 2,
        },
    },
    {
        model = {
            tag = "gjing4",
            speed = 2,
        },
    },
    {
        model = {
            tag = "gjing1",
            speed = 2,
        },
    },
    {
        model = {
            tag = "gjing2",
            speed = 2,
        },
    },

    {
       delay = {time = 0.4,},
    },

        {action = {tag  = "gjing1", sync = false,
                what = {fadeout = {time = 0.4,},},},},

        {action = {tag  = "gjing3", sync = false,
                what = {fadeout = {time = 0.4,},},},},





    {
       delay = {time = 0.4,},
    },



        {action = {tag  = "gjing2", sync = false,
                what = {fadeout = {time = 0.4,},},},},

        {action = {tag  = "gjing4", sync = false,
                what = {fadeout = {time = 0.4,},},},},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(60,-100),    order     = 45,
            file = "hero_guojing",    animation = "pugong",
            scale = 0.15,   parent = "clip_1", opacity=255,
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


    {   model = {
            tag  = "gjing211",     type  = DEF.FIGURE,
            pos= cc.p(150,-100),    order     = 45,
            file = "hero_guojing",    animation = "pugong",
            scale = 0.15,   parent = "clip_1", opacity=0,
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "gjing411",     type  = DEF.FIGURE,
            pos= cc.p(-30,-100),    order     = 45,
            file = "hero_guojing",    animation = "pugong",
            scale = 0.15,   parent = "clip_1", opacity=0,
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


    {
       delay = {time = 0.5,},
    },

       {remove = { model = {"gjing21", }, },},

    {
        model = {
            tag = "gjing211",
            opacity = 155,
        },
    },

    {
       delay = {time = 0.5,},
    },

       {remove = { model = {"gjing41", }, },},

    {
        sound = {file = "hero_guojing_nuji.mp3",sync=false,},
    },
    {
        model = {
            tag = "gjing411",
            opacity = 155,
        },
    },

    {
       delay = {time = 0.75,},
    },

    {
        model = {
            tag = "gjing",
            speed = 0.5,
        },
    },
    {
        model = {
            tag = "gjing211",
            speed = 0.5,
        },
    },
    {
        model = {
            tag = "gjing411",
            speed = 0.5,
        },
    },

    {action = {tag  = "gjing",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.3,to = cc.p(150,-100),
                                 control={cc.p(60,-100),cc.p(100,150),}
    },},},
    },},},




    {action = {tag  = "gjing211",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.3,to = cc.p(150,-250),
                                 control={cc.p(150,-100),cc.p(150,100),}
    },},},
    },},},

    {action = {tag  = "gjing411",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,0),},},
    {bezier = {time = 0.3,to = cc.p(150,0),
                                 control={cc.p(-30,-100),cc.p(50,200),}
    },},},
    },},},


        {remove = { model = {"long1","long2","long5","long6", }, },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.7","-120","-100"},},
     },

    {
       delay = {time = 0.575,},
    },


        {remove = { model = {"hdu", }, },},

    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(500,-100),    order     = 35,
            file = "hero_huodu",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},
    {action = {tag  = "hdu",sync = false,what ={ spawn={{bezier = {time = 1.5,to = cc.p(1000,200),
                                 control={cc.p(800,200),cc.p(1000,200),}
    },},
    {rotate = {to = cc.vec3(0, 180, 30),time = 1.5,},},},
    },},},


        {remove = { model = {"nmxing", }, },},

    {   model = {
            tag  = "nmxing",     type  = DEF.FIGURE,
            pos= cc.p(500,-300),    order     = 35,
            file = "hero_nimoxing",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},
    {action = {tag  = "nmxing",sync = false,what ={ spawn={{bezier = {time = 1.5,to = cc.p(1000,0),
                                 control={cc.p(800,0),cc.p(1000,0),}
    },},
    {rotate = {to = cc.vec3(0, 180, 30),time = 1.5,},},},
    },},},




        {remove = { model = {"gszhi", }, },},
    {   model = {
            tag  = "gszhi",     type  = DEF.FIGURE,
            pos= cc.p(500,100),    order     = 35,
            file = "hero_gongsunzhi",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},
    {action = {tag  = "gszhi",sync = false,what ={ spawn={{bezier = {time = 1.5,to = cc.p(1000,400),
                                 control={cc.p(800,400),cc.p(1000,400),}
    },},
    {rotate = {to = cc.vec3(0, 180, 30),time = 1.5,},},},
    },},},





        {remove = { model = {"hbweng1",}, },},
        {remove = { model = { "ykxi1", }, },},
        {remove = { model = {"ykang1",  }, },},





     {action = {
             tag  = "gjing211",sync = false,what = {
             spawn = {{move = {time = 0.5,to= cc.p(150, 0), },},{fadeout = {time = 0.5,},},},
            },},},

     {action = {
             tag  = "gjing411",sync = true,what = {
             spawn = {{move = {time = 0.5,to= cc.p(150, 0), },},{fadeout = {time = 0.5,},},},
            },},},


    {
       delay = {time = 0.5,},
    },


        {remove = { model = {"gszhi", }, },},
        {remove = { model = {"nmxing",  }, },},
        {remove = { model = {"hdu", }, },},
        {remove = { model = {"gjing", }, },},


        {remove = { model = {"oyke",  }, },},
        {remove = { model = {"fyao", }, },},
        {remove = { model = {"qqren", }, },},

    {
        load = {tmpl = "mod21",
            params = {"oyke","hero_ouyangke","750","-100","0.15","clip_1","25"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"fyao","hero_fanyao","600","100","0.15","clip_1","15"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"qqren","hero_qiuqianren","600","-300","0.15","clip_1","50"},},
    },






    {
        load = {tmpl = "mod22",
            params = {"gjing","hero_guojing","150","-100","0.15","clip_1","50"},},
    },

       {remove = { model = {"hrong", }, },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-100,-300),    order     = 55,
            file = "hero_huangrong",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},
    {action = {tag  = "hrong",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {move = {time = 0.8,to = cc.p(250,-100),}
    },},},
    },},

       {remove = { model = {"hrong", }, },},

    {
        load = {tmpl = "mod21",
            params = {"hrong","hero_huangrong","250","-100","0.15","clip_1","50"},},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
    --  {
    --      load = {tmpl = "move2",
    --          params = {"hr","hr.png","黄蓉"},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"hr",TR("靖哥哥！你还好吧！"),94},},
    --  },

    --  {
    --      load = {tmpl = "move1",
    --          params = {"gj","gj.png","郭靖"},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"gj",TR("蓉儿！我没事！"),95},},
    --  },

    -- {
    --     load = {tmpl = "out3",
    --         params = {"gj","hr"},},
    -- },







     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","-300","-100"},},
     },


     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("郭靖！你以为这样就完了吗！——有请法王和郡主！"),96},},
     },

    {
        load = {tmpl = "out2",
            params = {"oyk"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"hbweng","hero_hebiweng","-1600","100","0.15","clip_1","35"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"lzke","hero_luzhangke","-1500","0","0.15","clip_1","36"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"zmin","hero_zhaomin","-1400","50","0.15","clip_1","25"},},
    },


    {
        load = {tmpl = "mod22",
            params = {"jlfwang","hero_jinlunfawang","-1400","-250","0.15","clip_1","50"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lmchou","hero_limochou","-1500","-200","0.15","clip_1","45"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"xxzi","hero_xiaoxiangzi","-1600","-300","0.15","clip_1","50"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","1.2","0.7","500","-100"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {action = {tag  = "jlfwang",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-600,-250),
                                 control={cc.p(-1400,-300),cc.p(-900,300),}
    },},},
    },},},

    {action = {tag  = "lmchou",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-750,-200),
                                 control={cc.p(-1500,-300),cc.p(-900,300),}
    },},},
    },},},
    {action = {tag  = "xxzi",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-850,-300),
                                 control={cc.p(-1750,-300),cc.p(-900,300),}
    },},},
    },},},

    {action = {tag  = "zmin",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-600,50),
                                 control={cc.p(-1400,-300),cc.p(-900,600),}
    },},},
    },},},

    {action = {tag  = "lzke",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.14,},},
    {bezier = {time = 0.3,to = cc.p(-750,0),
                                 control={cc.p(-1500,-300),cc.p(-900,600),}
    },},},
    },},},
    {action = {tag  = "hbweng",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.14,},},
    {bezier = {time = 0.3,to = cc.p(-850,100),
                                 control={cc.p(-1750,-300),cc.p(-900,600),}
    },},},
    },},},


    {
       delay = {time = 0.5,},
    },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"oyk",TR("郭靖！我看你还能活多久！"),97},},
     -- },

    -- {
    --     load = {tmpl = "out2",
    --         params = {"oyk"},},
    -- },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","0","-100"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "xxzi",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.15,},},
    {bezier = {time = 0.3,to = cc.p(-250,-100),
                                 control={cc.p(-850,-300),cc.p(-400,200),}
    },},},
    },},},

    {
       delay = {time = 0.5,},
    },

       {remove = { model = {"gjing", }, },},

    {
        load = {tmpl = "mod21",
            params = {"gjing","hero_guojing","150","-100","0.15","clip_1","50"},},
    },


     {
         load = {tmpl = "move1",
             params = {"xxz","xxz.png",TR("潇湘子")},},
     },
     {
         load = {tmpl = "talk",
             params = {"xxz",TR("在下潇湘子，前来领教！"),98},},
     },

    {
        load = {tmpl = "out1",
            params = {"xxz"},},
    },
       {remove = { model = {"text-board", }, },},



    {
        model = {
            tag   = "diao",
            type  = DEF.PIC,
            scale = 0.16,
            pos   = cc.p(1500, 500),
            order = 40,
            file  = "diao.png",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },




    {
        load = {tmpl = "mod21",
            params = {"xlnv","hero_xiaolongnv","320","145","0.18","diao","-30"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"yguo","hero_yangguo","350","170","0.18","diao","-55"},},
    },

    {
       delay = {time = 0.5,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","1.5","-2250","-800"},},
     },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.5","1.5","-450","-800"},},
     },

    {
        sound = {file = "hero_huazheng_nuji.mp3",sync=false,},
    },

    {action = {tag  = "diao",sync = true,what ={ spawn={{scale= {time = 1.5,to = 0.3,},},
    {bezier = {time = 1.5,to = cc.p(300,500),
                                 control={cc.p(1100,500),cc.p(700,500),}
    },},},
    },},},

       {remove = { model = {"xlnv", "yguo",}, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(300,500),    order     = 65,
            file = "hero_xiaolongnv",    animation = "pose",
            scale = 0.05,   parent = "clip_1",opacity=255,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(320,500),    order     = 60,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.05,   parent = "clip_1",opacity=255,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,-15),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "diao",sync = false,what ={ spawn={{scale= {time = 1,to = 0.3,},},
    {bezier = {time = 1,to = cc.p(-1000,500),
                                 control={cc.p(-500,500),cc.p(-750,500),}
    },},},
    },},},



     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","1","-200","-200"},},
     },

    {action = {tag  = "xlnv",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.5,to = cc.p(200,350),
                                 control={cc.p(300,500),cc.p(600,400),}
    },},},
    },},},
    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.5,to = cc.p(350,350),
                                 control={cc.p(320,500),cc.p(800,400),}
    },},},
    },},},
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


    {remove = { model = {"yguo", }, },},

    -- {   model = {
    --         tag  = "yguo1",     type  = DEF.FIGURE,
    --         pos= cc.p(0,780),    order     = 82,
    --         file = "effect_lihui_yangguo",    animation = "animation",
    --         scale = 0.08,
    --         loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
    --     },},

     {
        model = {
            tag   = "yguo1",
            type  = DEF.PIC,
            scale = 0.15,
            pos   = cc.p(0, 780),
            order = 82,
            file  = "yglh.png",rotation3D=cc.vec3(0,0,0),
        },
    },


    {action = {tag  = "yguo1",sync = false,what ={ spawn={{scale= {time = 0.9,to = 1.2,},},
    {bezier = {time = 0.9,to = cc.p(280,640),
                                 control={cc.p(0,580),cc.p(240,180),}
    },},},
    },},},


     {
        model = {
            tag   = "xlnv2",
            type  = DEF.PIC,
            scale = 0.15,
            pos   = cc.p(640, 780),
            order = 85,
            file  = "xlnlh.png",rotation3D=cc.vec3(0,180,0),
        },
    },



    {action = {tag  = "xlnv2",sync = true,what ={ spawn={{scale= {time = 0.9,to = 1.2,},},
    {bezier = {time = 0.9,to = cc.p(330,500),
                                 control={cc.p(0,580),cc.p(240,180),}
    },},},
    },},},


    {
        delay = {time = 0.8,},
    },

    {
        sound = {file = "hero_yangguo_nuji.mp3",sync=false,},
    },

    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-100,-100),    order     = 65,
            file = "hero_yangguo",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},



     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.2","0.7","-200","-50"},},
     },

    -- {action = {tag  = "hdu",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.15,},},
    -- {move = {time = 0.1,by = cc.p(-100,0),}
    -- },},},
    -- },},
    -- {action = {tag  = "zmin",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.15,},},
    -- {move = {time = 0.1,by = cc.p(-100,0),}
    -- },},},
    -- },},

       {remove = { model = {"xxzi", }, },},
    {
        load = {tmpl = "mod21",
            params = {"xxzi","hero_xiaoxiangzi","-250","-100","0.15","clip_1","50"},},
    },






    {
        delay = {time = 0.2,},
    },
    {remove = { model = {"xlnv2", "yguo1", "heimu","mapbj1","diao",}, },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.8","0.7","100","-50"},},
     },

        {remove = { model = {"xxzi", }, },},

    {   model = {
            tag  = "xxzi",     type  = DEF.FIGURE,
            pos= cc.p(-250,-100),    order     = 50,
            file = "hero_xiaoxiangzi",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},



    {action = {tag  = "yguo",sync = false,what ={ spawn={{bezier = {time = 1,to = cc.p(-200,-300),
                                 control={cc.p(-100,-100),cc.p(-150,-200),}
    },},},
    },},},

    {
        delay = {time = 0.5,},
    },

    {action = {tag  = "xxzi",sync = true,what ={ spawn={{bezier = {time = 0.5,to = cc.p(-600,-300),
                                 control={cc.p(-250,-100),cc.p(-450,0),}
    },},
    {rotate = {to = cc.vec3(0, 0, -30),time = 0.5,},},},
    },},},





        {remove = { model = {"xxzi", }, },},
    -- {
    --     load = {tmpl = "mod22",
    --         params = {"nmxing","hero_nimoxing","-50","-300","0.15","clip_1","70"},},
    -- },
        {remove = { model = {"yguo", }, },},

    {
        load = {tmpl = "mod21",
            params = {"yguo","hero_yangguo","-200","-300","0.15","clip_1","68"},},
    },

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(650,500),    order     = 65,
            file = "hero_xiaolongnv",    animation = "pose",
            scale = 0.05,   parent = "clip_1",opacity=255,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "xlnv",sync = true,what ={ spawn={{scale= {time = 0.6,to = 0.15,},},
    {bezier = {time = 0.6,to = cc.p(-100,-320),
                                 control={cc.p(650,500),cc.p(250,800),}
    },},},
    },},},
        {remove = { model = {"xlnv", }, },},

    {
        load = {tmpl = "mod21",
            params = {"xlnv","hero_xiaolongnv","-100","-320","0.15","clip_1","65"},},
    },

    {
        delay = {time = 0.2,},
    },

        {remove = { model = {"yguo", }, },},

    {
        load = {tmpl = "mod22",
            params = {"yguo","hero_yangguo","-200","-300","0.15","clip_1","68"},},
    },




    {
        delay = {time = 0.3,},
    },

    --  {
    --      load = {tmpl = "jtt",
    --          params = {"clip_1","0.8","3","450","500"},},
    --  },

    -- {
    --     delay = {time = 0.1,},
    -- },




    --  {
    --      load = {tmpl = "move2",
    --          params = {"xln","xln.png","小龙女"},},
    --  },
    --  {
    --      load = {tmpl = "talk",
    --          params = {"xln",TR("过儿！"),"k0002.mp3"},},
    --  },
    --  {
    --      load = {tmpl = "move1",
    --          params = {"yg","yg.png","杨过"},},
    --  },

    --  {
    --      load = {tmpl = "talk",
    --          params = {"yg",TR("龙儿！"),"k0001.mp3"},},
    --  },


    -- {
    --     load = {tmpl = "out3",
    --         params = {"yg","xln"},},
    -- },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","0.7","250","-50"},},
     },




    --  {
    --      load = {tmpl = "move1",
    --          params = {"lmc","lmc.png","李莫愁"},},
    --  },
    --  {
    --      load = {tmpl = "talk",
    --          params = {"lmc",TR("狗男女！"),99},},
    --  },

    -- {
    --     load = {tmpl = "out1",
    --         params = {"lmc"},},
    -- },


        {remove = { model = {"yguo", }, },},

    {
        load = {tmpl = "mod21",
            params = {"yguo","hero_yangguo","-200","-300","0.15","clip_1","68"},},
    },

    {
        delay = {time = 0.2,},
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
             params = {"jlfw",TR("杨过！你不在古墓过你神仙眷侣的生活？又跑到江湖上来做什么？"),100},},
     },

     {
         load = {tmpl = "move2",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"yg",TR("我本无意再入江湖，但是秘宝现世，江湖大乱在即！"),101},},
     },

     {
         load = {tmpl = "talk2",
             params = {"yg",TR("若不阻止你们，我和龙儿又怎么能安心隐居！"),102},},
     },


    {
        load = {tmpl = "out3",
            params = {"jlfw","yg"},},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","1","650","-250"},},
     },




     -- {
     --     load = {tmpl = "talk",
     --         params = {"zm",TR("诸位！我们人多，不用怕他们！"),103},},
     -- },






       {remove = { model = {"zmin", }, },},

    {
        load = {tmpl = "mod21",
            params = {"zmin","hero_zhaomin","-600","50","0.15","clip_1","25"},},
    },


    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "move1",
             params = {"zm","zm.png",TR("赵敏")},},
     },

     {
         load = {tmpl = "talk",
             params = {"zm",TR("玄冥二老！就请你们二位出手一次！"),104},},
     },

     -- {
     --     load = {tmpl = "move2",
     --         params = {"lzk","lzk.png","鹿杖客"},},
     -- },
     -- {
     --     load = {tmpl = "talk",
     --         params = {"lzk",TR("是！郡主！"),105},},
     -- },
    {
        load = {tmpl = "out1",
            params = {"zm"},},
    },
    -- {
    --     load = {tmpl = "out3",
    --         params = {"zm","lzk"},},
    -- },
       {remove = { model = {"text-board", }, },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.3","0.7","150","-50"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "lzke",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.14,},},
    {bezier = {time = 0.3,to = cc.p(-360,-100),
                                 control={cc.p(-750,0),cc.p(-500,600),}
    },},},
    },},},
    {action = {tag  = "hbweng",sync = false,what ={ spawn={{scale= {time = 0.3,to = 0.13,},},
    {bezier = {time = 0.3,to = cc.p(-300,100),
                                 control={cc.p(-850,100),cc.p(-600,700),}
    },},},
    },},},


       {remove = { model = {"zmin", }, },},

    {
        load = {tmpl = "mod22",
            params = {"zmin","hero_zhaomin","-600","50","0.15","clip_1","25"},},
    },


    {
        delay = {time = 0.2,},
    },
    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
     {
         load = {tmpl = "move2",
             params = {"zwj","zwj.png",TR("张无忌")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zwj",TR("玄冥二老！我们之间的账，该算算了！"),106},},
     },

    {
        load = {tmpl = "out2",
            params = {"zwj"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","1","-200","-300"},},
     },
     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.8","1","100","-300"},},
     },

     -- {
     --     load = {tmpl = "jtttb",
     --         params = {"clip_1","0.5","1","100","-300"},},
     -- },

    {   model = {
            tag  = "zwji",     type  = DEF.FIGURE,
            pos= cc.p(400,300),    order     = 25,
            file = "effect_lihui_zhangwuji",    animation = "animation",
            scale = 0.05,   parent = "clip_1",opacity=255,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,10),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zwji",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.15,},},
    {bezier = {time = 0.5,to = cc.p(0,500),
                                 control={cc.p(400,400),cc.p(100,700),}
    },},},
    },},},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","4","0","-2000"},},
     },


    {
        delay = {time = 1.5,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.7","70","-210"},},
     },


     {
         load = {tmpl = "move1",
             params = {"lzk","lzk.png",TR("鹿杖客")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lzk",TR("啊！？——张无忌！"),107},},
     },
    {
        load = {tmpl = "out1",
            params = {"lzk"},},
    },

    --    {remove = { model = {"zwji", }, },},


    --  {
    --      load = {tmpl = "move2",
    --          params = {"zwj","zwj.png","张无忌"},},
    --  },
    --  {
    --      load = {tmpl = "talk",
    --          params = {"zwj",TR("斗转星移，乾坤无极——乾坤大挪移！"),108},},
    --  },
    -- {
    --     load = {tmpl = "out2",
    --         params = {"zwj"},},
    -- },

    {
        sound = {file = 108,sync=false,},
    },

    {
        delay = {time = 4.5,},
    },

       {remove = { model = {"text-board", }, },},


    {
        sound = {file = "skill_xiangmogong.mp3",sync=false,},
    },
    {
        sound = {file = "skill_xiangmogong.mp3",sync=false,},
    },
    {   model = {
            tag  = "xmg1",     type  = DEF.FIGURE,
            pos= cc.p(-150,-50),    order     = 60,
            file = "effect_wg_xiangmogong",    animation = "animation",
            scale = 0.5,parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "xmg2",     type  = DEF.FIGURE,
            pos= cc.p(-180,0),    order     = 60,
            file = "effect_wg_xiangmogong",    animation = "animation",
            scale = 0.5,parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},
    {   model = {
            tag  = "xmg3",     type  = DEF.FIGURE,
            pos= cc.p(-200,50),    order     = 60,
            file = "effect_wg_xiangmogong",    animation = "animation",
            scale = 0.5,parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},



    {
        delay = {time = 0.5,},
    },


       {remove = { model = {"lzke", "hbweng", }, },},

    {   model = {
            tag  = "lzke",     type  = DEF.FIGURE,
            pos= cc.p(-360,-100),    order     = 50,
            file = "hero_luzhangke",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "lzke",sync = false,what ={ spawn={{bezier = {time = 0.3,to = cc.p(-600,0),
                                 control={cc.p(-360,-100),cc.p(-450,0),}
    },},
    {rotate = {to = cc.vec3(0, 0, -30),time = 0.3,},},},
    },},},

    {   model = {
            tag  = "hbweng",     type  = DEF.FIGURE,
            pos= cc.p(-300,100),    order     = 50,
            file = "hero_hebiweng",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "hbweng",sync = true,what ={ spawn={{bezier = {time = 0.3,to = cc.p(-600,200),
                                 control={cc.p(-300,200),cc.p(-450,400),}
    },},
    {rotate = {to = cc.vec3(0, 0, -30),time = 0.3,},},},
    },},},

       {remove = { model = {"lzke", "hbweng", }, },},
       {remove = { model = {"xmg1", "xmg2","xmg3",  }, },},


       {remove = { model = {"zwji", }, },},

    {   model = {
            tag  = "zwji",     type  = DEF.FIGURE,
            pos= cc.p(0,500),    order     = 25,
            file = "hero_zhangwuji",    animation = "pose",
            scale = 0.12,   parent = "clip_1",opacity=255,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,10),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zwji",sync = false,what ={ spawn={{scale= {time = 0.4,to = 0.15,},},
    {bezier = {time = 0.4,to = cc.p(-150,100),
                                 control={cc.p(0,500),cc.p(-100,500),}
    },},},
    },},},

    {
        load = {tmpl = "mod21",
            params = {"zsfeng","hero_zhangsanfeng","500","300","0.05","clip_1","30"},},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zsfeng",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.14,},},
    {bezier = {time = 0.4,to = cc.p(0,100),
                                 control={cc.p(500,400),cc.p(200,700),}
    },},},
    },},},



       {remove = { model = {"zwji", }, },},

    {
        load = {tmpl = "mod21",
            params = {"zwji","hero_zhangwuji","-150","100","0.14","clip_1","30"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.3","0.7","200","-100"},},
     },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"zm","zm.png",TR("赵敏")},},
     },

     {
         load = {tmpl = "talk",
             params = {"zm",TR("无忌公子，你真是根搅屎棍，哪儿都少不了你！"),109},},
     },

     {
         load = {tmpl = "move2",
             params = {"zwj","zwj.png",TR("张无忌")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zwj",TR("郡主，你这话——是说你自己吧！"),110},},
     },

     {
         load = {tmpl = "talk",
             params = {"zm",TR("你！哼！这次我可不会再手下留情！"),111},},
     },

     -- {
     --     load = {tmpl = "talk1",
     --         params = {"zwj",TR("郡主，你可要摸着良心说话，哪次——不都是我对你手下留情……"),112},},
     -- },

     -- {
     --     load = {tmpl = "talk2",
     --         params = {"zwj",TR("郡主你放心，这次我依然会手下留情，不过——小小的惩罚可是免不了的！"),113},},
     -- },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"zm",TR("你……你想干什么？"),114},},
     -- },

    {
        load = {tmpl = "out3",
            params = {"zm","zwj"},},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.6","0.7","-300","-100"},},
     },

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("大家一起上，杀了他们！"),115},},
     },

    {
        load = {tmpl = "out2",
            params = {"oyk"},},
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
