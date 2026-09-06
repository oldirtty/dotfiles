// glide_out.glsl — window-close, ported from niri's glide.kdl
// https://github.com/jgarza9788/niri-animation-collection/blob/main/animations/glide.kdl

vec4 animation(vec2 uv) {

    float p = umbriel_clamped_progress;
    float inv = 1.0 - p;

    // Slight downward departure: 0px at start, 40px at end.
    float slide_px = p * 40.0;
    float slide_uv = slide_px / max(umbriel_size.x, 1.0);

    // Tiny scale-down on exit: 1.0 -> 0.988.
    float scale = 1.0 - 0.012 * p;

    vec2 coords = uv - vec2(0.5, 0.5);
    coords /= scale;
    coords += vec2(0.5, 0.5);
    coords.y -= slide_uv;

    vec4 color = umbriel_sample(coords);

    // Gentle fade-out: 1 -> 0.
    color *= inv;

    return color;
}
