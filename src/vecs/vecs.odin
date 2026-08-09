package vecs

//---------------------------------------------------------
// Vector2 for INT 
//---------------------------------------------------------
V2 :: struct {
    x, y: int,
}

v2 :: proc {
    v2_scalar,
    v2_xy,
}

v2_scalar :: proc(s: int) -> V2 {
    return V2{x = s, y = s}
}

v2_xy :: proc(x, y: int) -> V2 {
    return V2{x = x, y = y}
}
