import { chromium } from "playwright";
import { resolve } from "path";

const [htmlPath, pdfPath] = process.argv.slice(2);
if (!htmlPath || !pdfPath) {
  console.error(`Usage: node scripts/build_pdf.mjs <input.html> <output.pdf>`);
  process.exit(1);
}

const html = resolve(htmlPath);
const pdf = resolve(pdfPath);

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(`file://${html}`, { waitUntil: "networkidle" });
await page.pdf({
  path: pdf,
  format: "A4",
  printBackground: true,
  margin: { top: "15mm", right: "0", bottom: "15mm", left: "0" },
  displayHeaderFooter: false,
});
await browser.close();

console.log(`Generated ${pdf}`);
