import math
import os
from PIL import Image, ImageDraw, ImageFont

def render_watchface(theme_index=0, current_steps=7410, target_steps=10000, readiness_val=88):
    themes = [
        {"name": "Lavanda", "text": "#E9D5FF", "neon": "#C084FC", "dark": "#4C1D95", "track": "#281446"},
        {"name": "fsociety Red", "text": "#FFE4E6", "neon": "#F43F5E", "dark": "#881337", "track": "#38101C"},
        {"name": "Kali Green", "text": "#DCFCE7", "neon": "#22C55E", "dark": "#14532D", "track": "#0D2E17"},
        {"name": "Cyber Cyan", "text": "#E0F2FE", "neon": "#06B6D4", "dark": "#164E63", "track": "#0D2E3A"},
        {"name": "Amber", "text": "#FEF3C7", "neon": "#F59E0B", "dark": "#78350F", "track": "#3A2206"},
        {"name": "Stealth White", "text": "#FFFFFF", "neon": "#CBD5E1", "dark": "#334155", "track": "#1E293B"},
    ]
    t = themes[theme_index]
    col_text = t["text"]
    col_neon = t["neon"]
    col_dark = t["dark"]
    col_track = t["track"]

    font_mrrobot_42 = ImageFont.truetype(r"app\src\main\res\font\mr_robot.ttf", 42)
    font_mono_16 = ImageFont.truetype(r"app\src\main\res\font\roboto_mono_bold.ttf", 16)
    font_mono_18 = ImageFont.truetype(r"app\src\main\res\font\roboto_mono_bold.ttf", 18)
    font_mono_13 = ImageFont.truetype(r"app\src\main\res\font\roboto_mono_bold.ttf", 13)
    font_mono_12 = ImageFont.truetype(r"app\src\main\res\font\roboto_mono_bold.ttf", 12)

    wf = Image.new("RGBA", (450, 450), (0, 0, 0, 255))
    draw = ImageDraw.Draw(wf)

    cx, cy = 225, 225
    R = 195 # Prominent complication radius (diameter 390)
    bar_thickness = 15 # Bold chunky bar matching Image 2 reference

    def draw_curved_text(text, font, color, start_angle, end_angle, radius, ccw=False):
        bbox = font.getbbox(text)
        total_w = bbox[2] - bbox[0]
        text_angle_span = (total_w / radius) * (180.0 / math.pi)
        
        mid_angle = (start_angle + end_angle) / 2.0
        if not ccw:
            start_char_angle = mid_angle - (text_angle_span / 2.0)
            char_step = text_angle_span / max(1, len(text))
            for i, ch in enumerate(text):
                ch_mid = start_char_angle + (i + 0.5) * char_step
                rad = math.radians(ch_mid - 90)
                px = cx + radius * math.cos(rad)
                py = cy + radius * math.sin(rad)

                char_img = Image.new("RGBA", (56, 56), (0, 0, 0, 0))
                cdraw = ImageDraw.Draw(char_img)
                cbbox = font.getbbox(ch)
                cw = cbbox[2] - cbbox[0]
                ch_h = cbbox[3] - cbbox[1]
                cdraw.text((28 - cw//2, 28 - ch_h//2), ch, font=font, fill=color)

                rot_deg = -ch_mid
                rotated_char = char_img.rotate(rot_deg, resample=Image.Resampling.BILINEAR)
                wf.paste(rotated_char, (int(px - 28), int(py - 28)), rotated_char)
        else:
            start_char_angle = mid_angle + (text_angle_span / 2.0)
            char_step = text_angle_span / max(1, len(text))
            for i, ch in enumerate(text):
                ch_mid = start_char_angle - (i + 0.5) * char_step
                rad = math.radians(ch_mid - 90)
                px = cx + radius * math.cos(rad)
                py = cy + radius * math.sin(rad)

                char_img = Image.new("RGBA", (56, 56), (0, 0, 0, 0))
                cdraw = ImageDraw.Draw(char_img)
                cbbox = font.getbbox(ch)
                cw = cbbox[2] - cbbox[0]
                ch_h = cbbox[3] - cbbox[1]
                cdraw.text((28 - cw//2, 28 - ch_h//2), ch, font=font, fill=color)

                rot_deg = -(ch_mid + 180)
                rotated_char = char_img.rotate(rot_deg, resample=Image.Resampling.BILINEAR)
                wf.paste(rotated_char, (int(px - 28), int(py - 28)), rotated_char)

    def draw_curved_icon(icon_type, color, angle_deg, radius, size=28):
        rad = math.radians(angle_deg - 90)
        ix = cx + radius * math.cos(rad)
        iy = cy + radius * math.sin(rad)

        icon_img = Image.new("RGBA", (44, 44), (0, 0, 0, 0))
        idraw = ImageDraw.Draw(icon_img)
        icx, icy = 22, 22

        if icon_type == "weather":
            idraw.ellipse((icx-8, icy-8, icx+8, icy+8), fill=color)
            for a in range(0, 360, 45):
                arad = math.radians(a)
                x1 = icx + 9 * math.cos(arad)
                y1 = icy + 9 * math.sin(arad)
                x2 = icx + 14 * math.cos(arad)
                y2 = icy + 14 * math.sin(arad)
                idraw.line([(x1, y1), (x2, y2)], fill=color, width=2)
        elif icon_type == "heart":
            idraw.polygon([(icx, icy+11), (icx-11, icy-2), (icx-8, icy-9), (icx-3, icy-9), (icx, icy-5), (icx+3, icy-9), (icx+8, icy-9), (icx+11, icy-2)], fill=color)
        elif icon_type == "readiness":
            idraw.rounded_rectangle((icx-7, icy-11, icx+7, icy+11), radius=3, outline=color, width=3)
            idraw.rectangle((icx-3, icy-14, icx+3, icy-11), fill=color)
            idraw.rectangle((icx-4, icy-5, icx+4, icy+8), fill=color)
        elif icon_type == "steps":
            idraw.ellipse((icx-8, icy-7, icx+7, icy+2), fill=color)
            idraw.polygon([(icx-8, icy), (icx+9, icy), (icx+7, icy+8), (icx-5, icy+8)], fill=color)

        rot_deg = -angle_deg
        rotated_icon = icon_img.rotate(rot_deg, resample=Image.Resampling.BILINEAR)
        wf.paste(rotated_icon, (int(ix - 22), int(iy - 22)), rotated_icon)

    def draw_thick_arc(start_deg, end_deg, color, width, radius):
        p_start = start_deg - 90
        p_end = end_deg - 90
        bbox = (cx - radius, cy - radius, cx + radius, cy + radius)
        draw.arc(bbox, start=p_start, end=p_end, fill=color, width=width)
        for ang in [start_deg, end_deg]:
            arad = math.radians(ang - 90)
            ex = cx + radius * math.cos(arad)
            ey = cy + radius * math.sin(arad)
            draw.ellipse((ex - width/2, ey - width/2, ex + width/2, ey + width/2), fill=color)

    # 1. Subtle Accent Ring
    draw.ellipse((cx - 213, cy - 213, cx + 213, cy + 213), outline="#1A0D2E", width=1)

    # 2. Dividers
    draw.line([(85, 214), (365, 214)], fill=col_dark, width=2)
    draw.line([(110, 274), (340, 274)], fill=col_dark, width=2)

    # 3. Center Terminal HUD (Clean, no overlap with corners!)
    draw.text((cx, 64), "root@fsociety:~#", font=font_mono_12, fill=col_neon, anchor="mm")
    draw.text((cx, 88), "HELLO, FRIEND.", font=font_mono_18, fill=col_text, anchor="mm")
    draw.text((cx, 146), "15:15:57", font=font_mrrobot_42, fill=col_neon, anchor="mm")
    draw.text((cx, 196), "> SYS_DATE: 2026.09.16 // Wed", font=font_mono_13, fill=col_text, anchor="mm")
    draw.text((cx, 236), "FSOCIETY_OS // ENCRYPT: AES-256", font=font_mono_12, fill=col_neon, anchor="mm")
    draw.text((cx, 258), "STATUS: ROOT PRIVILEGES GRANTED", font=font_mono_12, fill=col_text, anchor="mm")
    draw.text((cx, 320), "root@fsociety:~# _", font=font_mono_13, fill=col_neon, anchor="mm")

    # 4. COMPLICATIONS (Tight, bold, large typography, thick bars matching Image 2)
    # Slot 0: Top-Left (Weather) -> NO ARC!
    draw_curved_icon("weather", col_neon, 304, R, size=28)
    draw_curved_text("24°C", font_mono_18, col_text, 314, 334, R, ccw=False)

    # Slot 1: Top-Right (Heart Rate) -> NO ARC!
    draw_curved_icon("heart", col_neon, 30, R, size=28)
    draw_curved_text("72 BPM", font_mono_18, col_text, 40, 62, R, ccw=False)

    # Slot 2: Bottom-Left (Readiness / Battery) -> RANGED VALUE
    # Thick target background bar (subtle dark): 226° to 256° (30° sweep)
    draw_thick_arc(226, 256, col_track, width=bar_thickness, radius=R)
    # Thick progress bar (solid bright neon): fraction
    rdn_fraction = min(1.0, max(0.0, readiness_val / 100.0))
    rdn_end = 226 + (30 * rdn_fraction)
    draw_thick_arc(226, rdn_end, col_neon, width=bar_thickness, radius=R)
    # Text in COUNTER_CLOCKWISE (right side up!)
    draw_curved_text(f"{readiness_val}%", font_mono_18, col_text, 222, 206, R, ccw=True)
    # Icon
    draw_curved_icon("readiness", col_neon, 196, R, size=28)

    # Slot 3: Bottom-Right (Steps Goal) -> RANGED VALUE
    # Icon
    draw_curved_icon("steps", col_neon, 108, R, size=28)
    # Text
    draw_curved_text(f"{current_steps:,}".replace(",", " "), font_mono_18, col_text, 118, 136, R, ccw=False)
    # Thick target background bar (subtle dark): 140° to 170° (30° sweep)
    draw_thick_arc(140, 170, col_track, width=bar_thickness, radius=R)
    # Thick progress bar (solid bright neon): fraction
    steps_fraction = min(1.0, max(0.0, current_steps / target_steps))
    steps_end = 140 + (30 * steps_fraction)
    draw_thick_arc(140, steps_end, col_neon, width=bar_thickness, radius=R)

    return wf

def generate_emulator_device(wf):
    device = Image.new("RGBA", (550, 550), (18, 18, 22, 255))
    ddraw = ImageDraw.Draw(device)

    ddraw.ellipse((30, 30, 520, 520), fill="#24242A", outline="#35353F", width=2)
    ddraw.rounded_rectangle((512, 245, 528, 305), radius=4, fill="#50505A", outline="#656575", width=1)
    ddraw.ellipse((42, 42, 508, 508), fill="#0A0A0E", outline="#1A1A22", width=3)

    mask = Image.new("L", (450, 450), 0)
    mdraw = ImageDraw.Draw(mask)
    mdraw.ellipse((0, 0, 450, 450), fill=255)

    device.paste(wf, (50, 50), mask)

    glass = Image.new("RGBA", (550, 550), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glass)
    gdraw.arc((48, 48, 502, 502), start=210, end=330, fill=(255, 255, 255, 35), width=3)
    device = Image.alpha_composite(device, glass)

    return device

if __name__ == "__main__":
    wf = render_watchface(theme_index=0)
    preview = generate_emulator_device(wf)

    out_wf = r"F:\Dev\techIncubator\watchFace\app\src\main\res\drawable\preview.jpg"
    out_device = r"F:\Dev\techIncubator\watchFace\emulator_preview.png"
    out_artifact = r"C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\mrrobot_emulator_preview.png"

    wf.convert("RGB").save(out_wf, "JPEG", quality=95)
    preview.save(out_device)
    preview.save(out_artifact)
    print("Faithful preview rendered and saved!")
