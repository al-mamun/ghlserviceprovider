from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.platypus import Paragraph
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "output" / "fiverr-ghl-missed-call-documents"
OUT_DIR.mkdir(parents=True, exist_ok=True)
PDF_PATH = OUT_DIR / "gohighlevel-missed-call-automation-portfolio.pdf"

PORTRAIT = Path(r"D:\personal\my pic\my-pro.jpeg")
MAIN_IMAGE = ROOT / "output" / "fiverr-ghl-missed-call-images" / "ghl-missed-call-main.png"
WORKFLOW_IMAGE = ROOT / "output" / "fiverr-ghl-missed-call-images" / "ghl-missed-call-workflow.png"

PAGE_W, PAGE_H = A4

NAVY = colors.HexColor("#102033")
INK = colors.HexColor("#263445")
MUTED = colors.HexColor("#607083")
GREEN = colors.HexColor("#22C55E")
DARK = colors.HexColor("#07111F")
DARK_2 = colors.HexColor("#10382F")
BLUE = colors.HexColor("#075985")
LIGHT_BLUE = colors.HexColor("#E8F7FF")
LIGHT_GREEN = colors.HexColor("#E9FFF6")
LIGHT_ORANGE = colors.HexColor("#FFF4E6")
SOFT = colors.HexColor("#F3F7FB")
BORDER = colors.HexColor("#DCE6EF")
PURPLE = colors.HexColor("#4C1D95")


def round_rect(c, x, y, w, h, r, fill, stroke=None, sw=1):
    c.setFillColor(fill)
    c.setStrokeColor(stroke or fill)
    c.setLineWidth(sw)
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


def header(c, label):
    round_rect(c, 36, PAGE_H - 62, PAGE_W - 72, 34, 10, colors.white, BORDER, 0.8)
    text(c, "GoHighLevel Missed Call Automation", 52, PAGE_H - 50, 10.5, MUTED, "Helvetica-Bold")
    centered(c, label, PAGE_W - 220, PAGE_H - 55, 160, 22, 9.5, BLUE)


def footer(c, page_no):
    c.setStrokeColor(BORDER)
    c.setLineWidth(0.6)
    c.line(44, 42, PAGE_W - 44, 42)
    text(c, "Message me before ordering so I can review your GoHighLevel workflow requirements.", 50, 26, 8.5, MUTED)
    text(c, str(page_no), PAGE_W - 58, 26, 8.5, MUTED, "Helvetica-Bold")


def pill(c, label, x, y, w, fill, color=INK):
    round_rect(c, x, y, w, 25, 12.5, fill)
    centered(c, label, x, y, w, 25, 9.5, color)


def bullet(c, value, x, y, w, accent=GREEN):
    c.setFillColor(accent)
    c.circle(x + 5, y - 4, 3, fill=1, stroke=0)
    return paragraph(c, value, x + 18, y + 4, w - 18, 10.2, 14, INK)


def dark_page(c):
    c.setFillColor(DARK)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColor(DARK_2)
    c.rect(PAGE_W * 0.45, 0, PAGE_W * 0.55, PAGE_H, fill=1, stroke=0)
    c.setStrokeColor(colors.Color(1, 1, 1, alpha=0.08))
    c.setLineWidth(0.5)
    for x in range(0, int(PAGE_W), 42):
        c.line(x, 0, x, PAGE_H)
    for y in range(0, int(PAGE_H), 42):
        c.line(0, y, PAGE_W, y)


def mini_flow(c, x, y):
    stages = [
        ("Missed Call", LIGHT_ORANGE, colors.HexColor("#B45309")),
        ("Auto SMS", LIGHT_GREEN, colors.HexColor("#087F5B")),
        ("AI Reply", colors.HexColor("#EDEBFF"), PURPLE),
        ("CRM Pipeline", LIGHT_BLUE, BLUE),
    ]
    cx = x
    for i, (label, fill, color) in enumerate(stages):
        round_rect(c, cx, y, 108, 44, 12, fill, BORDER, 0.5)
        centered(c, label, cx, y, 108, 44, 9.4, color)
        if i < len(stages) - 1:
            c.setStrokeColor(GREEN)
            c.setLineWidth(2)
            c.line(cx + 114, y + 22, cx + 134, y + 22)
            c.line(cx + 134, y + 22, cx + 128, y + 28)
            c.line(cx + 134, y + 22, cx + 128, y + 16)
        cx += 142


def page_one(c):
    dark_page(c)
    round_rect(c, 38, 56, PAGE_W - 76, PAGE_H - 112, 22, colors.HexColor("#0B1726"), GREEN, 1.8)
    text(c, "GoHighLevel Automation", 60, PAGE_H - 124, 14, GREEN, "Helvetica-Bold")
    text(c, "Missed Call", 60, PAGE_H - 184, 31, colors.white, "Helvetica-Bold")
    text(c, "Text Back System", 60, PAGE_H - 222, 31, colors.white, "Helvetica-Bold")
    paragraph(
        c,
        "A practical automation setup that helps businesses reply faster, capture more leads, and move new inquiries into a GoHighLevel pipeline.",
        62,
        PAGE_H - 266,
        300,
        12,
        17,
        colors.HexColor("#C9D6E4"),
    )
    pill(c, "SMS", 62, PAGE_H - 352, 70, LIGHT_GREEN, colors.HexColor("#087F5B"))
    pill(c, "AI Reply", 144, PAGE_H - 352, 92, colors.HexColor("#EDEBFF"), PURPLE)
    pill(c, "Pipeline", 248, PAGE_H - 352, 94, LIGHT_BLUE, BLUE)
    round_rect(c, 62, PAGE_H - 456, 294, 74, 14, GREEN)
    centered(c, "Never lose a lead from missed calls", 62, PAGE_H - 456, 294, 74, 13.5, colors.HexColor("#062C22"))
    if MAIN_IMAGE.exists():
        c.drawImage(str(MAIN_IMAGE), 374, 326, width=165, height=99, preserveAspectRatio=True, mask="auto")
    if PORTRAIT.exists():
        c.drawImage(str(PORTRAIT), 388, 442, width=140, height=182, preserveAspectRatio=True, mask="auto")
        round_rect(c, 382, 436, 152, 194, 12, colors.Color(1, 1, 1, alpha=0), GREEN, 1.5)
    text(c, "Best for:", 60, 188, 13, GREEN, "Helvetica-Bold")
    paragraph(c, "Local businesses, agencies, coaches, clinics, real estate, home services, salons, consultants and service-based businesses.", 62, 166, PAGE_W - 124, 10.8, 15, colors.HexColor("#E6EEF7"))
    footer(c, 1)
    c.showPage()


def page_two(c):
    header(c, "Problem")
    text(c, "The Problem This Automation Solves", 48, PAGE_H - 112, 24, NAVY, "Helvetica-Bold")
    paragraph(c, "Many businesses lose leads because missed calls are not followed up quickly. This setup sends an automatic text back, starts follow-up, updates the CRM and helps your team respond faster.", 50, PAGE_H - 142, PAGE_W - 100, 11.4, 16, INK)
    round_rect(c, 54, PAGE_H - 292, PAGE_W - 108, 88, 16, LIGHT_ORANGE, BORDER, 0.6)
    text(c, "Before", 80, PAGE_H - 236, 14, colors.HexColor("#B45309"), "Helvetica-Bold")
    paragraph(c, "A lead calls, no one answers, no follow-up happens, and the buyer may contact a competitor.", 80, PAGE_H - 256, PAGE_W - 160, 10.8, 15, INK)
    round_rect(c, 54, PAGE_H - 414, PAGE_W - 108, 88, 16, LIGHT_GREEN, BORDER, 0.6)
    text(c, "After", 80, PAGE_H - 358, 14, colors.HexColor("#087F5B"), "Helvetica-Bold")
    paragraph(c, "GoHighLevel sends a text back, starts AI or SMS/email follow-up, updates pipeline status and notifies your team.", 80, PAGE_H - 378, PAGE_W - 160, 10.8, 15, INK)
    text(c, "Simple Lead Flow", 54, PAGE_H - 478, 16, NAVY, "Helvetica-Bold")
    mini_flow(c, 54, PAGE_H - 542)
    round_rect(c, 54, 92, PAGE_W - 108, 80, 16, SOFT, BORDER, 0.6)
    paragraph(c, "<b>Result:</b> faster replies, cleaner CRM tracking, better lead capture, and a more professional customer experience.", 78, 142, PAGE_W - 156, 11.2, 16, NAVY)
    footer(c, 2)
    c.showPage()


def page_three(c):
    dark_page(c)
    round_rect(c, 30, 30, PAGE_W - 60, PAGE_H - 60, 22, colors.Color(1, 1, 1, alpha=0), colors.HexColor("#203A4D"), 1.2)
    text(c, "Workflow Setup", 54, PAGE_H - 102, 29, colors.white, "Helvetica-Bold")
    paragraph(c, "A clean GoHighLevel workflow should be easy to understand, test and scale. I structure automations so the logic is organized and practical.", 56, PAGE_H - 132, PAGE_W - 112, 11.2, 16, colors.HexColor("#C9D6E4"))
    if WORKFLOW_IMAGE.exists():
        c.drawImage(str(WORKFLOW_IMAGE), 50, 346, width=494, height=297, preserveAspectRatio=True, mask="auto")
    items = [
        ("Trigger", "Missed call or new lead activity starts the workflow."),
        ("Message", "SMS/email copy is customized for your business."),
        ("AI Follow Up", "AI or guided reply helps qualify and guide the lead."),
        ("CRM Update", "Tags, pipeline stage and notifications keep your team informed."),
    ]
    y = 304
    for title, body in items:
        round_rect(c, 56, y - 58, PAGE_W - 112, 66, 14, colors.white)
        round_rect(c, 76, y - 38, 26, 26, 13, GREEN)
        centered(c, "", 76, y - 38, 26, 26, 8, colors.HexColor("#062C22"))
        text(c, title, 118, y - 18, 13.5, NAVY, "Helvetica-Bold")
        paragraph(c, body, 118, y - 36, PAGE_W - 190, 9.8, 13.5, MUTED)
        y -= 82
    footer(c, 3)
    c.showPage()


def page_four(c):
    header(c, "Process")
    text(c, "How I Set It Up", 48, PAGE_H - 112, 24, NAVY, "Helvetica-Bold")
    paragraph(c, "Before building, I review your goal, phone setup, pipeline, message copy and follow-up rules so the workflow matches your real business process.", 50, PAGE_H - 142, PAGE_W - 100, 11.4, 16, INK)
    steps = [
        ("1", "Review Account", "Check your GoHighLevel phone setup, pipeline, calendar and workflow requirements."),
        ("2", "Build Automation", "Set up missed call SMS, AI reply, tags, pipeline updates and notifications."),
        ("3", "Customize Messages", "Adjust SMS/email copy, timing, logic and conditions for your business."),
        ("4", "Test and Deliver", "Test the workflow and confirm leads are captured and routed correctly."),
    ]
    y = PAGE_H - 226
    for num, title, body in steps:
        round_rect(c, 58, y - 62, PAGE_W - 116, 76, 14, SOFT, BORDER, 0.5)
        round_rect(c, 78, y - 42, 38, 38, 19, GREEN)
        centered(c, num, 78, y - 42, 38, 38, 13, colors.HexColor("#062C22"))
        text(c, title, 136, y - 18, 14, NAVY, "Helvetica-Bold")
        paragraph(c, body, 136, y - 36, PAGE_W - 218, 10.2, 14, MUTED)
        y -= 94
    text(c, "What I Need From You", 58, 206, 16, NAVY, "Helvetica-Bold")
    requirements = [
        "GoHighLevel access or invite",
        "Connected phone number status",
        "Missed call SMS and follow-up message preferences",
        "Pipeline, calendar, form or notification details",
    ]
    y = 178
    for item in requirements:
        y = bullet(c, item, 62, y, PAGE_W - 124)
        y -= 9
    round_rect(c, 58, 70, PAGE_W - 116, 48, 14, NAVY)
    centered(c, "Ready to capture missed-call leads? Message me before ordering.", 58, 70, PAGE_W - 116, 48, 12, colors.white)
    footer(c, 4)
    c.showPage()


def main():
    c = canvas.Canvas(str(PDF_PATH), pagesize=A4)
    c.setTitle("GoHighLevel Missed Call Automation Portfolio")
    c.setAuthor("Fiverr GoHighLevel Automation Specialist")
    page_one(c)
    page_two(c)
    page_three(c)
    page_four(c)
    c.save()
    print(PDF_PATH)


if __name__ == "__main__":
    main()
