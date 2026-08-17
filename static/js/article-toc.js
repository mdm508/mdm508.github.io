(() => {
  const tocContainers = Array.from(document.querySelectorAll("[data-article-toc]"));
  if (tocContainers.length === 0) return;

  const links = Array.from(document.querySelectorAll('[data-article-toc] a[href^="#"]'));
  const ids = Array.from(new Set(
    links
      .map((link) => decodeURIComponent(link.hash.slice(1)))
      .filter(Boolean)
  ));
  const headings = ids
    .map((id) => document.getElementById(id))
    .filter(Boolean);

  if (headings.length === 0) return;

  const currentLabels = Array.from(document.querySelectorAll(".article-toc__current"));
  let activeId = "";
  let ticking = false;

  const setActive = (heading) => {
    if (!heading || heading.id === activeId) return;
    activeId = heading.id;

    links.forEach((link) => {
      const isActive = decodeURIComponent(link.hash.slice(1)) === activeId;
      link.classList.toggle("is-active", isActive);
      if (isActive) {
        link.setAttribute("aria-current", "location");
      } else {
        link.removeAttribute("aria-current");
      }
    });

    currentLabels.forEach((label) => {
      label.textContent = heading.textContent.trim();
    });
  };

  const updateActiveSection = () => {
    const readingLine = window.scrollY + Math.min(window.innerHeight * 0.28, 220);
    let current = headings[0];

    headings.forEach((heading) => {
      if (heading.offsetTop <= readingLine) current = heading;
    });

    setActive(current);
    ticking = false;
  };

  window.addEventListener("scroll", () => {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(updateActiveSection);
  }, { passive: true });

  links.forEach((link) => {
    link.addEventListener("click", () => {
      const compact = link.closest(".article-toc--compact");
      if (compact) compact.open = false;
    });
  });

  updateActiveSection();
})();
