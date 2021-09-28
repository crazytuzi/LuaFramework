
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
        music = {file = "battle4.mp3",},
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
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1.5,
            pos   = cc.p(-900, -320),
            order = -99,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scaleX = 1.5, scaleY=3,
            pos   = cc.p(-900,-1200),
            order = -100,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scaleX = 1.5, scaleY=3,
            pos   = cc.p(-900,-900),
            order = -101,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },




    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-1400","360","0.04","clip_1","70"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"lb","hero_nvzhu","-850","510","0.03","clip_1","50"},},
    },




    {
        model = {
            tag       = "guangxiao",     type      = DEF.FIGURE,
            pos= cc.p(-1180,500),     order     = 40,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1.2,        loop      = true,opacity=150,
            endRlease = false,         parent = "clip_1", speed=0.8,rotation3D=cc.vec3(0,0,0),
        },},
    {
        model = {
            tag       = "guangxiao2",     type      = DEF.FIGURE,
            pos= cc.p(-1180,500),     order     = 41,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1.2,        loop      = true,opacity=250,
            endRlease = false,         parent = "clip_1", speed=1.2,rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = {
            tag       = "chuansong1",     type      = DEF.FIGURE,
            pos= cc.p(-1150,286),     order     = 30,
            file      = "effect_ui_chuansongmen",         animation = "zeizhao",
            scaleX     = 1.6,   scaleY=1.2  ,    loop      = true, opacity=100,
            endRlease = false,         parent = "clip_1", speed=1,
        },},
    {
        model = {
            tag       = "chuansong",     type      = DEF.FIGURE,
            pos= cc.p(-1180,480),     order     = 35,
            file      = "effect_ui_chuansongmen",         animation = "chuansongmen",
            scaleX     = 0.8,   scaleY     = 0.6,       loop      = true,
            endRlease = false,         parent = "clip_1", speed=0.3,
        },},


     {
         load = {tmpl = "mod3111",
             params = {"effect_ui_shenbingqjinjie","0.25","-1180","450","clip_1"},},
     },



    -- {delay={time=0.15},},

    {
        model = {
            tag       = "xiangzi",     type      = DEF.FIGURE,
            pos= cc.p(-1175,470),     order     = 101,
            file      = "effect_jinlun",         animation = "animation",
            scale     = 0.09,         loop      = true,
            endRlease = false,         parent = "clip_1", speed=2,
        },},


    {
        model = { tag = "yupan",type  = DEF.PIC,
                  file  = "yp.png",order = 100,scale=0.1,
                  pos   = cc.p(-1180, 450),parent = "clip_1",rotation3D=cc.vec3(30,30,0),},
    },



    {
        load = {tmpl = "mod22",
            params = {"zwji","hero_zhangwuji","-2100","100","0.22","clip_1","30"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"zsfeng","hero_zhangsanfeng","-2100","100","0.22","clip_1","30"},},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.5","480","180"},},
     },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },




    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 50,
            file = "hero_guojing",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-1800,0),    order     = 45,
            file = "hero_huangrong",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "gjing",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-500,-200),
                                 control={cc.p(-2100,0),cc.p(-700,300),}
    },},},
    },},},
    {
       delay = {time = 0.3,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "hrong",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-700,-200),
                                 control={cc.p(-2100,0),cc.p(-900,300),}
    },},},
    },},},
    {
       delay = {time = 0.5,},
    },

       {remove = { model = {"gjing", }, },},
    {
        load = {tmpl = "mod22",
            params = {"gjing","hero_guojing","-500","-200","0.22","clip_1","50"},},
    },
    {
       delay = {time = 0.3,},
    },

       {remove = { model = {"hrong", }, },},


    {
        load = {tmpl = "mod22",
            params = {"hrong","hero_huangrong","-700","-200","0.22","clip_1","50"},},
    },
    {
       delay = {time = 0.2,},
    },
       {remove = { model = {"gjing", }, },},

    {
        load = {tmpl = "mod21",
            params = {"gjing","hero_guojing","-500","-200","0.22","clip_1","50"},},
    },
    {
       delay = {time = 0.2,},
    },

       {remove = { model = {"hrong", }, },},

    {
        load = {tmpl = "mod21",
            params = {"hrong","hero_huangrong","-700","-200","0.22","clip_1","50"},},
    },



    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-1800,-300),    order     = 50,
            file = "hero_yangguo",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1800,-300),    order     = 45,
            file = "hero_xiaolongnv",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-800,-500),
                                 control={cc.p(-2100,0),cc.p(-1000,300),}
    },},},
    },},},
    {
       delay = {time = 0.3,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "xlnv",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-1000,-500),
                                 control={cc.p(-2100,0),cc.p(-1200,300),}
    },},},
    },},},
       {remove = { model = {"yguo", }, },},
       {remove = { model = {"xlnv", }, },},
    {
        load = {tmpl = "mod22",
            params = {"yguo","hero_yangguo","-800","-500","0.22","clip_1","50"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"xlnv","hero_xiaolongnv","-1000","-500","0.22","clip_1","50"},},
    },
    {
       delay = {time = 0.2,},
    },
       {remove = { model = {"yguo", }, },},

    {
        load = {tmpl = "mod21",
            params = {"yguo","hero_yangguo","-800","-500","0.22","clip_1","50"},},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zwji",sync = false,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-1200,-300),
                                 control={cc.p(-2100,0),cc.p(-1300,300),}
    },},},
    },},},
    {
       delay = {time = 0.3,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zsfeng",sync = true,what ={ spawn={{scale= {time = 0.5,to = 0.22,},},
    {bezier = {time = 0.8,to = cc.p(-1400,-300),
                                 control={cc.p(-2100,0),cc.p(-1500,300),}
    },},},
    },},},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.5","560","0"},},
     },
     {
         load = {tmpl = "jtt",
             params = {"clip_1","1","1","1120","-400"},},
     },
    {
       delay = {time = 0.5,},
    },
     {
         load = {tmpl = "jtt",
             params = {"clip_1","1","0.5","480","0"},},
     },


    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(-600,-120),    order     = 85,
            file = "hero_ouyangfeng",    animation = "pose",
            scale = 0.06,   parent = "clip_1",opacity=0,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,60),
        },},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.8","0.75","720","-300"},},
     },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "oyfeng",sync = true,what ={ spawn={{scale= {time = 0.8,to = 0.14,},},
    {fadein= {time = 0.4,},},
    {bezier = {time = 0.8,to = cc.p(-1100,400),
                                 control={cc.p(-600,900),cc.p(-1800,600),}
    },},},
    },},},

    {
        sound = {file = "hero_ouyangfeng_nuji2.mp3",sync=false,},
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
            tag  = "oyfeng1",     type  = DEF.FIGURE,
            pos= cc.p(-1100,400),    order     = 73,
            file = "hero_ouyangfeng",    animation = "daiji",
            scale = 0.17,parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},
    {   model = {
            tag  = "heimu",     type  = DEF.FIGURE,
            pos= cc.p(320,560),    order     = 81,
            file = "effect_nujifenwei",    animation = "animation",
            scale = 0.96,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

       {remove = { model = {"oyfeng", }, },},

    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(360,640),    order     = 82,
            file = "hero_ouyangfeng",    animation = "nuji",
            scale = 0.15,
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.4","400","0"},},
     },

    {
       delay = {time = 4.2,},
    },

    {
        sound = {file = "skill_hamagong.mp3",sync=false,},
    },

    {
        sound = {file = "skill_hamagong.mp3",sync=false,},
    },

    {
        sound = {file = "skill_hamagong.mp3",sync=false,},
    },
    {   model = {
            tag  = "hamagong1",     type  = DEF.FIGURE,
            pos= cc.p(-1100,400),    order     = 76,
            file = "effect_wg_hamagong",    animation = "animation",
            scale = 0.96, parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,-90),
        },},

    {   model = {
            tag  = "hamagong2",     type  = DEF.FIGURE,
            pos= cc.p(-1100,400),    order     = 76,
            file = "effect_wg_hamagong",    animation = "animation",
            scale = 0.96, parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,-120),
        },},

    {   model = {
            tag  = "hamagong3",     type  = DEF.FIGURE,
            pos= cc.p(-1100,400),    order     = 76,
            file = "effect_wg_hamagong",    animation = "animation",
            scale = 0.96, parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,-150),
        },},



    {remove = { model = {"oyfeng", "heimu","mapbj1",}, },},

    -- {
    --     model = {
    --         tag = "oyfeng1",
    --         speed = 0,
    --     },
    -- },
    {action = {tag  = "oyfeng1",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.12,},},
    {move = {time = 0.2,to = cc.p(-930,300),}
    },},},
    },},


    {action = {tag  = "hamagong1",sync = false,what ={ spawn={{scale= {time = 0.5,to = 1.22,},},
    {move = {time = 0.5,to = cc.p(-1200,50),}
    },},},
    },},

    {action = {tag  = "hamagong2",sync = false,what ={ spawn={{scale= {time = 0.5,to = 1.22,},},
    {move = {time = 0.5,to = cc.p(-800,-150),}
    },},},
    },},
    {action = {tag  = "hamagong3",sync = false,what ={ spawn={{scale= {time = 0.5,to = 1.22,},},
    {move = {time = 0.5,to = cc.p(-500,150),}
    },},},
    },},

    {
       delay = {time = 0.4,},
    },

    {remove = { model = {"yguo", "xlnv","gjing","hrong", "zwji", "zsfeng", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-800,-500),    order     = 50,
            file = "hero_yangguo",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1000,-500),    order     = 45,
            file = "hero_xiaolongnv",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-500,-200),    order     = 50,
            file = "hero_guojing",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-700,-200),    order     = 45,
            file = "hero_huangrong",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zwji",     type  = DEF.FIGURE,
            pos= cc.p(-1200,-300),    order     = 50,
            file = "hero_zhangwuji",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "zsfeng",     type  = DEF.FIGURE,
            pos= cc.p(-1400,-300),    order     = 45,
            file = "hero_zhangsanfeng",    animation = "aida",
            scale = 0.22,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(0,-100),}
    },},},
    },},

    {action = {tag  = "xlnv",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(0,-100),}
    },},},
    },},
    {action = {tag  = "gjing",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(150,-100),}
    },},},
    },},
    {action = {tag  = "hrong",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(150,-100),}
    },},},
    },},
    {action = {tag  = "zwji",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(-150,-100),}
    },},},
    },},
    {action = {tag  = "zsfeng",sync = false,what ={ spawn={{scale= {time = 0.25,to = 0.22,},},
    {move = {time = 0.25,by = cc.p(-150,-100),}
    },},},
    },},
    {
       delay = {time = 0.25,},
    },

    {remove = { model = {"yguo", "xlnv","gjing","hrong", "zwji", "zsfeng", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-800,-600),    order     = 50,
            file = "hero_yangguo",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-1000,-600),    order     = 45,
            file = "hero_xiaolongnv",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-350,-300),    order     = 50,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-550,-300),    order     = 45,
            file = "hero_huangrong",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zwji",     type  = DEF.FIGURE,
            pos= cc.p(-1350,-400),    order     = 50,
            file = "hero_zhangwuji",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "zsfeng",     type  = DEF.FIGURE,
            pos= cc.p(-1550,-400),    order     = 45,
            file = "hero_zhangsanfeng",    animation = "daiji",
            scale = 0.22,   parent = "clip_1",
            loop = true,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.5","450","-100"},},
     },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("欧阳锋，你枉为一代宗师，竟然用偷袭这种卑鄙伎俩！"),119},},
     },

    {
        load = {tmpl = "out1",
            params = {"gj"},},
    },

     {
         load = {tmpl = "move2",
             params = {"oyf","oyf.png",TR("欧阳锋")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyf",TR("秘宝是我的，我才是真正的天下第一！"),120},},
     },

     -- {
     --     load = {tmpl = "talk2",
     --         params = {"oyf",TR("天下第一，我是天下第一！"),"k039.mp3"},},
     -- },



    {
        load = {tmpl = "out2",
            params = {"oyf"},},
    },



       {remove = { model = {"text-board", }, },},






    -- {
    --     load = {tmpl = "mod22",
    --         params = {"zjue","_lead_","-1400","360","0.04","clip_1","50"},},
    -- },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","1","1160","-500"},},
     },
     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.5","0.8","800","-400"},},
     -- },
       -- {remove = { model = {"zjue", }, },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.8,to = 0.08,},},
    {fadein= {time = 0.4,},},
    {bezier = {time = 0.8,to = cc.p(-1200,700),
                                 control={cc.p(-1800,60),cc.p(-1300,100),}
    },},},
    },},},

    --    {remove = { model = {"zjue", }, },},

    -- {   model = {
    --         tag  = "zjue",     type  = DEF.FIGURE,
    --         pos= cc.p(-1200,700),    order     = 70,
    --         file = "_lead_",    animation = "nuji",
    --         scale = 0.08,   parent = "clip_1",
    --         loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,0,0),
    --     },},


    {remove = { model = {"zjue", }, },},
    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(-1200,700),    order     = 75,
            file = "_lead_",    animation = "pugong",
            scale = 0.08,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },


    {action = {tag  = "lbyi",sync = false,what ={ spawn={{scale= {time = 0.6,to  = 0.13,},},
        {bezier = {time = 1.5,to = cc.p(-930,300),
                                 control={cc.p(-1200,700),cc.p(-1200,200),}
    },},},},},},




    {
        delay = {time = 0.1,},
    },

    {   model = {
            tag  = "lbyi1",     type  = DEF.FIGURE,
            pos= cc.p(-1200,700),    order     = 75,
            file = "_lead_",    animation = "pugong",
            scale = 0.08,   parent = "clip_1",  opacity=150,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {action = {tag  = "lbyi1",sync = false,what ={ spawn={{scale= {time = 0.6,to  = 0.13,},},
        {bezier = {time = 1.5,to = cc.p(-930,300),
                                 control={cc.p(-1200,700),cc.p(-1200,200),}
    },},},},},},
    {
        delay = {time = 0.1,},
    },

    {   model = {
            tag  = "lbyi3",     type  = DEF.FIGURE,
            pos= cc.p(-1200,700),    order     = 75,
            file = "_lead_",    animation = "pugong",
            scale = 0.08,   parent = "clip_1", opacity=100,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {action = {tag  = "lbyi3",sync = false,what ={ spawn={{scale= {time = 0.6,to  = 0.13,},},
        {bezier = {time = 1.5,to = cc.p(-930,300),
                                 control={cc.p(-1200,700),cc.p(-1200,200),}
    },},},},},},

   {
        delay = {time = 0.1,},
    },
    {   model = {
            tag  = "lbyi5",     type  = DEF.FIGURE,
            pos= cc.p(-1200,700),    order     = 75,
            file = "_lead_",    animation = "pugong",
            scale = 0.08,   parent = "clip_1", opacity=50,
            loop = true,   endRlease = false,  speed=1.5, rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },
    {action = {tag  = "lbyi5",sync = false,what ={ spawn={{scale= {time = 0.6,to  = 0.13,},},
        {bezier = {time = 1.5,to = cc.p(-930,300),
                                 control={cc.p(-1200,700),cc.p(-1200,200),}
    },},},},},},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","0.5","300","-100"},},
     },


        {
         model = {
            tag  ="clip2",      type   = DEF.CLIPPING,     order     = 100,
            file = "bj.png",   scale    = 0.8,      pos= cc.p(360,720),},},


   {
        delay = {time = 0.8,},
    },


    -- {action = {tag  = "clip2",sync = false,what ={ spawn={{rotate= {time = 3.2,to  = cc.vec3(0,0,-30),},},
    -- {bezier = {time = 3,to = cc.p(860,900),
    --                              control={cc.p(560,640),cc.p(700,900),}
    -- },},},
    -- },},},
       {remove = { model = {"oyfeng1", }, },},
    {   model = {
            tag  = "oyfeng",     type  = DEF.FIGURE,
            pos= cc.p(40,-100),    order     = 73,
            file = "hero_ouyangfeng",    animation = "aida",
            scale = 0.12,parent = "clip2",
            loop = true,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},


    -- {action = {tag  = "oyfeng",sync = false,what ={ spawn={{rotate= {time = 0.2,to  = cc.vec3(0,180,0),},},
    -- {bezier = {time = 0.9,to = cc.p(0,0),
    --                              control={cc.p(-930,300),cc.p(-750,0),}
    -- },},},
    -- },},},

    {action = {tag  = "clip2",sync = false,what ={ spawn={{scale= {time = 1.5,to  =0,},},
    {move = {time = 0.9,to = cc.p(880,940),}
    },},},
    },},

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
        delay = {time = 0.9,},
    },

    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-930","300","0.14","clip_1","50"},},
    },




     -- {
     --     load = {tmpl = "jttb",
     --         params = {"clip_1","1","1","-300","0"},},
     -- },

    {remove = { model = {"lbyi", }, },},


    -- {   model = {
    --         tag  = "lbyi",     type  = DEF.FIGURE,
    --         pos= cc.p(-1200,700),    order     = 50,
    --         file = "_lead_",    animation = "pugong",
    --         scale = 0.15,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {action = {tag  = "lbyi",sync = false,what ={ spawn={{scale= {time = 0.3,to  = 0.13,},},
    -- {move = {time = 0.5,to = cc.p(-1000,300),}
    -- },},},},},

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


	{
        music = {file = "jq_yt.mp3",},
    },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("天下第一？就算是成了天下第一——又能如何？"),1},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("到头来，都不过是——转头成空！"),2},},
     },


    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },

    {
       delay = {time = 0.1,},
    },


    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},



    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },



----正式剧情




    {
	   delay = {time = 0.1,},
	},
}
