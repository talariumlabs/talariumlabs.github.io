// docs/assets/catalog.js
// Tiny, dependency-free helper for filtering RFC cards on the catalog page.
// Expects:
//  - a container with id="catalog"
//  - an input with id="catalog-search" (optional)
//  - a select with id="catalog-category"   (optional)
// Each RFC card should have data attributes:
//  - data-title="RFC 6442 — Location Conveyance for SIP"
//  - data-rfc="6442"
//  - data-categories="Representation,Conveyance"  (comma-separated)

(function () {
  const $ = document.querySelector.bind(document);
  const $$ = (sel) => Array.from(document.querySelectorAll(sel));

  const root = $("#catalog");
  if (!root) return; // Only run on pages that include a catalog

  const searchEl = $("#catalog-search");
  const categoryEl = $("#catalog-category");

  function matches(el, term, categoryVal) {
    const title = (el.getAttribute("data-title") || "").toLowerCase();
    const num = (el.getAttribute("data-rfc") || "").toLowerCase();
    const categories = (el.getAttribute("data-categories") || "")
      .split(",")
      .map((s) => s.trim());

    const termOk =
      !term ||
      title.includes(term) ||
      num.includes(term) ||
      // Allow "rfc6442" or "6442" style queries:
      ("rfc" + num).includes(term.replace(/\s+/g, ""));

    const categoryOk = !categoryVal || categories.includes(categoryVal);

    return termOk && categoryOk;
  }

  function applyFilters() {
    const term = (searchEl && searchEl.value.trim().toLowerCase()) || "";
    const categoryVal = (categoryEl && categoryEl.value) || "";

    $$("#catalog .rfc-card").forEach((card) => {
      card.style.display = matches(card, term, categoryVal) ? "" : "none";
    });
  }

  // Wire up events (if the controls exist)
  if (searchEl) searchEl.addEventListener("input", applyFilters);
  if (categoryEl) categoryEl.addEventListener("change", applyFilters);

  // Initial render
  applyFilters();
})();
