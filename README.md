# GHL Expert — Static Website

Premium static website for a GoHighLevel services expert. Built with clean HTML, CSS, and vanilla JavaScript. GitHub Pages compatible.

## Files

| File | Purpose |
|------|---------|
| `index.html` | Full website (all sections) |
| `style.css` | Complete design system (dark, glassmorphism, responsive) |
| `script.js` | Interactions, animations, FAQ, counters, form |
| `robots.txt` | Search engine + AI crawler directives |
| `sitemap.xml` | XML sitemap for search engines |
| `llms.txt` | AI search engine content summary |

## Deploy to GitHub Pages

1. Create a new GitHub repository (e.g., `ghl-expert-website`)
2. Upload all files to the repository root
3. Go to **Settings → Pages**
4. Under **Source**, select `main` branch and `/ (root)` folder
5. Click **Save**
6. Your site will be live at `https://yourusername.github.io/ghl-expert-website/`

## Custom Domain Setup

1. Purchase your domain (e.g., `yourdomain.com`)
2. In your domain registrar, add these DNS records:
   - A record: `185.199.108.153`
   - A record: `185.199.109.153`
   - A record: `185.199.110.153`
   - A record: `185.199.111.153`
   - CNAME: `www` → `yourusername.github.io`
3. In GitHub Pages settings, enter your custom domain
4. Enable **Enforce HTTPS**

## Customization Checklist

- [ ] Replace all `yourdomain.com` with your real domain in `index.html`, `sitemap.xml`, `llms.txt`, `robots.txt`
- [ ] Update `hello@yourdomain.com` with your real email
- [ ] Update WhatsApp link: `https://wa.me/YOUR_NUMBER`
- [ ] Replace calendar embed placeholder with your real GHL calendar embed code
- [ ] Update pricing amounts if different
- [ ] Add your real name/brand to footer and meta tags
- [ ] Update `og-image.jpg` — create a 1200×630px social share image
- [ ] Update `sitemap.xml` lastmod dates after changes

## Integrating the Contact Form

The form is UI-only by default. To receive submissions, choose one:

**Option A — Formspree (free, easiest):**
1. Sign up at formspree.io
2. Create a new form, get your endpoint URL
3. In `script.js`, replace the `await new Promise(...)` simulation with:
```js
const res = await fetch('https://formspree.io/f/YOUR_ID', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  body: JSON.stringify(Object.fromEntries(new FormData(form)))
});
```

**Option B — Netlify Forms (if hosting on Netlify):**
Add `netlify` attribute to your `<form>` tag.

**Option C — GHL Form Embed:**
Replace the contact form section with your GHL-hosted form embed code.

## Performance Tips

- Images: Convert any added images to WebP format
- SVG icons are already inline — no extra requests
- Fonts load from Google Fonts CDN with preconnect hints
- JavaScript is deferred — no render blocking
- Target Lighthouse score: 95+ on all metrics

## License

This code is for your personal/commercial use. GoHighLevel® is a registered trademark of HighLevel Inc. This site is not affiliated with GoHighLevel.
