package fonts 

import rl "vendor:raylib"

Fonts :: struct {
    regular: rl.Font,
    bold:    rl.Font,
}

init :: proc() -> Fonts {
    fonts := Fonts {
        regular = rl.LoadFont("assets/fonts/static/RobotoMono-Light.ttf"),
        bold    = rl.LoadFont("assets/fonts/static/RobotoMono-SemiBold.ttf"),
    }
    rl.SetTextureFilter(fonts.regular.texture, .BILINEAR)
    rl.SetTextureFilter(fonts.bold.texture, .BILINEAR)
    return fonts
}

destroy :: proc(fonts: ^Fonts) {
    rl.UnloadFont(fonts.regular)
    rl.UnloadFont(fonts.bold)
}
