from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.platypus import Paragraph
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "output" / "fiverr-gig-documents"
OUT_DIR.mkdir(parents=True, exist_ok=True)
PDF_PATH = OUT_DIR / "website-bug-fix-portfolio.pdf"

PORTRAIT = Path(r"D:\personal\my pic\my-pro.jpeg")
MAIN_IMAGE = ROOT / "output" / "fiverr-gig-images" / "website-bug-fix-main.png"
SKILLS_IMAGE = ROOT / "output" / "fiverr-gig-images" / "website-bug-fix-skills.png"

PAGE_W, PAGE_H = A4

NAVY = colors.HexColor("#102033")
INK = colors.HexColor("#263445")
MUTED = colors.HexColor("#607083")
GREEN = colors.HexColor("#20C997")
BLUE = colors.HexColor("#075985")
LIGHT_BLUE = colors.HexColor("#E8F7FF")
LIGHT_GREEN = colors.HexColor("#E9FFF6")
LIGHT_ORANGE = colors.HexColor("#FFF4E6")
SOFT = colors.HexColor("#F3F7FB")
BORDER = colors.HexColor("#DCE6EF")
RED = colors.HexColor("#EF4444")


def draw_round(c, x, y, w, h, r, fill, stroke=None, sw=1):
    c.setFillColor(fill)
    if stroke:
        c.setStrokeColor(stroke)
        c.setLineWidth(sw)
    else:
        c.setStrokeColor(fill)
    c.roundRect(x, y, w, h, r, fill=1, stroke=1 if stroke else 0)


def text(c, value, x, y, size=12, color=INK, font="Helvetica"):
    c.setFillColor(color)
    c.setFont(font, size)
    c.drawString(x, y, value)


def centered(c, value, x, y, w, h, size=12, color=INK, font="Helvetica-Bold"):
    c.setFillColor(color)
    c.setFont(font, size)
    tw = stringWidth(value, font, size)
    c.drawString(x + (w - tw) / 2, y + (h - size) / 2 + 2, value)


def paragraph(c, value, x, y_top, w, size=10.5, leading=15, color=INK, bold=False):
    style = ParagraphStyle(
        "body",
        fontName="Helvetica-Bold" if bold else "Helvetica",
        fontSize=size,
        leading=leading,
        textColor=color,
        spaceAfter=0,
    )
    p = Paragraph(value, style)
    _, h = p.wrap(w, 500)
    p.drawOn(c, x, y_top - h)
    return y_top - h


def header(c, page_title):
    draw_round(c, 36, PAGE_H - 62, PAGE_W - 72, 34, 10, colors.white, BORDER, 0.8)
    text(c, "Website Bug Fix Portfolio", 52, PAGE_H - 50, 10.5, MUTED, "Helvetica-Bold")
    centered(c, page_title, PAGE_W - 220, PAGE_H - 55, 160, 22, 9.5, BLUE)


def footer(c, page_no):
    c.setStrokeColor(BORDER)
    c.setLineWidth(0.6)
    c.line(44, 42, PAGE_W - 44, 42)
    text(c, "Message me before ordering so I can review your issue and recommend the right package.", 50, 26, 8.5, MUTED)
    text(c, str(page_no), PAGE_W - 58, 26, 8.5, MUTED, "Helvetica-Bold")


def bullet(c, value, x, y, w, accent=GREEN):
    c.setFillColor(accent)
    c.circle(x + 5, y - 4, 3, fill=1, stroke=0)
    return paragraph(c, value, x + 18, y + 4, w - 18, 10.2, 14, INK)


def draw_pill(c, label, x, y, w, fill, color=INK):
    draw_round(c, x, y, w, 25, 12.5, fill)
    centered(c, label, x, y, w, 25, 9.5, color)


def draw_browser(c, x, y, w, h, title, broken=False):
    draw_round(c, x, y, w, h, 12, colors.white, BORDER, 0.8)
    draw_round(c, x + 12, y + h - 34, w - 24, 22, 7, SOFT)
    c.setFillColor(colors.HexColor("#FF5F57"))
    c.circle(x + 26, y + h - 23, 3.5, fill=1, stroke=0)
    c.setFillColor(colors.HexColor("#FFBD2E"))
    c.circle(x + 39, y + h - 23, 3.5, fill=1, stroke=0)
    c.setFillColor(colors.HexColor("#28C840"))
    c.circle(x + 52, y + h - 23, 3.5, fill=1, stroke=0)
    text(c, title, x + 16, y + h - 58, 10, NAVY, "Helvetica-Bold")
    if broken:
        draw_round(c, x + 16, y + h - 98, w - 32, 28, 5, colors.HexColor("#FFE8E8"))
        text(c, "Broken form", x + 28, y + h - 88, 10.5, colors.HexColor("#B91C1C"), "Helvetica-Bold")
        c.setStrokeColor(RED)
        c.setLineWidth(3)
        c.line(x + 22, y + 72, x + w - 24, y + 90)
        c.line(x + 22, y + 52, x + w - 60, y + 32)
        draw_round(c, x + 18, y + 16, 70, 24, 5, colors.HexColor("#FEE2E2"))
        centered(c, "404", x + 18, y + 16, 70, 24, 10, colors.HexColor("#B91C1C"))
    else:
        draw_round(c, x + 16, y + h - 98, w - 32, 28, 5, LIGHT_GREEN)
        text(c, "Working form", x + 28, y + h - 88, 10.5, colors.HexColor("#087F5B"), "Helvetica-Bold")
        c.setStrokeColor(GREEN)
        c.setLineWidth(3)
        c.line(x + w - 44, y + h - 86, x + w - 35, y + h - 96)
        c.line(x + w - 35, y + h - 96, x + w - 20, y + h - 72)
        draw_round(c, x + 18, y + 70, w - 36, 10, 3, colors.HexColor("#D6E4F0"))
        draw_round(c, x + 18, y + 48, w - 74, 10, 3, colors.HexColor("#D6E4F0"))
        draw_round(c, x + 18, y + 16, 72, 25, 6, GREEN)
        centered(c, "Fixed", x + 18, y + 16, 72, 25, 10, colors.white)


def page_one(c):
    c.setFillColor(colors.HexColor("#F8FBFF"))
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    draw_round(c, 38, 56, PAGE_W - 76, PAGE_H - 112, 22, colors.white, BORDER, 0.8)
    draw_round(c, 58, PAGE_H - 128, 166, 28, 14, LIGHT_GREEN)
    centered(c, "Website Bug Fix Service", 58, PAGE_H - 128, 166, 28, 9.5, colors.HexColor("#087F5B"))
    text(c, "Professional Website", 58, PAGE_H - 188, 30, NAVY, "Helvetica-Bold")
    text(c, "Bug Fix Portfolio", 58, PAGE_H - 224, 30, NAVY, "Helvetica-Bold")
    paragraph(
        c,
        "I help businesses fix broken website layouts, forms, CSS, JavaScript, responsive issues, WordPress problems, custom code bugs, APIs, databases and backend functionality.",
        60,
        PAGE_H - 260,
        312,
        12.2,
        17,
        INK,
    )
    draw_round(c, 60, PAGE_H - 402, 300, 78, 14, SOFT)
    text(c, "Core promise", 82, PAGE_H - 354, 11, MUTED, "Helvetica-Bold")
    paragraph(c, "Fast communication, clean code, careful testing, and reliable delivery.", 82, PAGE_H - 372, 236, 11, 15, NAVY, True)
    draw_pill(c, "CSS", 60, PAGE_H - 448, 62, LIGHT_BLUE, BLUE)
    draw_pill(c, "Forms", 132, PAGE_H - 448, 80, LIGHT_GREEN, colors.HexColor("#087F5B"))
    draw_pill(c, "Mobile", 222, PAGE_H - 448, 88, LIGHT_ORANGE, colors.HexColor("#B45309"))
    draw_pill(c, "WordPress", 60, PAGE_H - 486, 110, LIGHT_BLUE, BLUE)
    draw_pill(c, "React", 180, PAGE_H - 486, 78, colors.HexColor("#EDEBFF"), colors.HexColor("#4C1D95"))
    draw_pill(c, "Laravel", 268, PAGE_H - 486, 92, colors.HexColor("#FFECEC"), colors.HexColor("#B91C1C"))
    if MAIN_IMAGE.exists():
        c.drawImage(str(MAIN_IMAGE), 385, 226, width=160, height=96, preserveAspectRatio=True, mask="auto")
    if PORTRAIT.exists():
        c.drawImage(str(PORTRAIT), 388, 392, width=150, height=196, preserveAspectRatio=True, mask="auto")
        draw_round(c, 383, 386, 160, 206, 12, colors.Color(1, 1, 1, alpha=0), GREEN, 2)
    footer(c, 1)
    c.showPage()


def page_two(c):
    header(c, "What I Fix")
    text(c, "Common Website Issues I Can Solve", 48, PAGE_H - 112, 24, NAVY, "Helvetica-Bold")
    paragraph(c, "This gig is designed for buyers who already have a website but something is broken, misaligned, slow, unresponsive, or not working as expected.", 50, PAGE_H - 140, PAGE_W - 100, 11.5, 16, INK)
    left_x, right_x, top = 54, 316, PAGE_H - 205
    items = [
        ("Layout and CSS", "Spacing, alignment, overlapping sections, styling bugs and broken visual design."),
        ("Forms and Buttons", "Contact forms, booking forms, validation, submit errors and button actions."),
        ("Responsive Issues", "Mobile, tablet and desktop layout problems across modern browsers."),
        ("JavaScript Bugs", "Menus, sliders, popups, errors, dynamic UI and frontend behavior fixes."),
        ("WordPress Fixes", "Elementor, WooCommerce, themes, plugin conflicts and admin-side issues."),
        ("Custom Code", "React, Next.js, Node.js, PHP, Laravel, API, database and backend bugs."),
    ]
    for i, (title, body) in enumerate(items):
        x = left_x if i % 2 == 0 else right_x
        y = top - (i // 2) * 126
        draw_round(c, x, y - 86, 226, 96, 14, SOFT, BORDER, 0.6)
        c.setFillColor(GREEN if i % 2 == 0 else colors.HexColor("#0EA5E9"))
        c.circle(x + 20, y - 20, 8, fill=1, stroke=0)
        text(c, title, x + 38, y - 24, 13, NAVY, "Helvetica-Bold")
        paragraph(c, body, x + 20, y - 44, 186, 9.4, 13, MUTED)
    text(c, "Example before and after", 54, 162, 15, NAVY, "Helvetica-Bold")
    draw_browser(c, 54, 52, 220, 96, "Before Fix", True)
    c.setStrokeColor(GREEN)
    c.setLineWidth(4)
    c.line(285, 100, 310, 100)
    c.line(310, 100, 300, 108)
    c.line(310, 100, 300, 92)
    draw_browser(c, 322, 52, 220, 96, "After Fix", False)
    footer(c, 2)
    c.showPage()


def page_three(c):
    header(c, "Tech Stack")
    text(c, "Technologies I Work With", 48, PAGE_H - 112, 24, NAVY, "Helvetica-Bold")
    paragraph(c, "I can handle both frontend and backend issues, so you do not need multiple sellers for one broken website problem.", 50, PAGE_H - 140, PAGE_W - 100, 11.5, 16, INK)
    if SKILLS_IMAGE.exists():
        c.drawImage(str(SKILLS_IMAGE), 52, 386, width=492, height=295, preserveAspectRatio=True, mask="auto")
    categories = [
        ("Frontend", ["HTML", "CSS", "JavaScript", "jQuery", "React", "Next.js"]),
        ("Backend", ["Node.js", "PHP", "Laravel", "Databases", "APIs", "Server-side bugs"]),
        ("CMS and Stores", ["WordPress", "Elementor", "WooCommerce", "Themes", "Plugins", "Forms"]),
    ]
    y = 342
    for title, tags in categories:
        text(c, title, 54, y, 14, NAVY, "Helvetica-Bold")
        x = 54
        for tag in tags:
            width = max(54, stringWidth(tag, "Helvetica-Bold", 9.5) + 24)
            if x + width > PAGE_W - 54:
                x = 54
                y -= 34
            draw_pill(c, tag, x, y - 36, width, LIGHT_BLUE if title != "Backend" else LIGHT_GREEN, BLUE if title != "Backend" else colors.HexColor("#087F5B"))
            x += width + 8
        y -= 72
    draw_round(c, 54, 74, PAGE_W - 108, 58, 14, LIGHT_GREEN)
    paragraph(c, "<b>Best fit:</b> broken pages, mobile issues, form problems, WordPress fixes, custom-code bugs, API errors, and small-to-medium frontend/backend repairs.", 74, 112, PAGE_W - 148, 11.2, 16, colors.HexColor("#062C22"))
    footer(c, 3)
    c.showPage()


def page_four(c):
    header(c, "Process")
    text(c, "How I Work On Your Website Issue", 48, PAGE_H - 112, 24, NAVY, "Helvetica-Bold")
    paragraph(c, "A clear process keeps the order smooth and helps me fix the real problem without unnecessary changes to your website.", 50, PAGE_H - 140, PAGE_W - 100, 11.5, 16, INK)
    steps = [
        ("1", "Review the Issue", "I check your website URL, screenshots, error messages and access requirements."),
        ("2", "Confirm the Scope", "I identify whether the problem is frontend, backend, WordPress, database, API or hosting related."),
        ("3", "Fix Carefully", "I repair the issue using clean code and avoid changing unrelated parts of your website."),
        ("4", "Test Before Delivery", "I test the fix on desktop/mobile and confirm the expected result before delivery."),
    ]
    y = PAGE_H - 220
    for num, title, body in steps:
        draw_round(c, 58, y - 62, PAGE_W - 116, 76, 14, SOFT, BORDER, 0.5)
        draw_round(c, 78, y - 42, 38, 38, 19, GREEN)
        centered(c, num, 78, y - 42, 38, 38, 13, colors.HexColor("#062C22"))
        text(c, title, 136, y - 18, 14, NAVY, "Helvetica-Bold")
        paragraph(c, body, 136, y - 36, PAGE_W - 218, 10.3, 14, MUTED)
        y -= 100
    text(c, "Buyer Requirements", 58, 212, 16, NAVY, "Helvetica-Bold")
    requirements = [
        "Website URL and exact page with the issue",
        "Screenshot, screen recording or error message if available",
        "Expected result after the fix",
        "Admin, hosting, FTP, GitHub or source code access if needed",
    ]
    y = 184
    for item in requirements:
        y = bullet(c, item, 62, y, PAGE_W - 124)
        y -= 10
    draw_round(c, 58, 70, PAGE_W - 116, 48, 14, NAVY)
    centered(c, "Ready to fix your website issue? Please message me before ordering.", 58, 70, PAGE_W - 116, 48, 12, colors.white)
    footer(c, 4)
    c.showPage()


def main():
    c = canvas.Canvas(str(PDF_PATH), pagesize=A4)
    c.setTitle("Website Bug Fix Portfolio")
    c.setAuthor("Fiverr Web Developer")
    page_one(c)
    page_two(c)
    page_three(c)
    page_four(c)
    c.save()
    print(PDF_PATH)


if __name__ == "__main__":
    main()
