#!/usr/bin/env bash
# build.sh — Convert all Markdown and text files to HTML and assemble the GitHub Pages site
set -euo pipefail

SITE="_site"
mkdir -p "$SITE/assets"

###############################################################################
# 1.  CSS
###############################################################################
cat > "$SITE/assets/style.css" << 'CSSEOF'
:root {
  --body-font: "Hiragino Mincho Pro", "Noto Serif JP", "Yu Mincho", Georgia, serif;
  --sans-font: "Hiragino Kaku Gothic Pro", "Noto Sans JP", "Yu Gothic", "Helvetica Neue", sans-serif;
  --max-width: 880px;
  --accent: #0055cc;
  --border: #d8d8d8;
}
html { font-size: 16px; }
body {
  font-family: var(--body-font);
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 2em 5em;
  line-height: 1.9;
  color: #1c1c1c;
  background: #fff;
}
h1, h2, h3, h4, h5, h6 {
  font-family: var(--sans-font);
  font-weight: bold;
  margin-top: 1.8em;
  line-height: 1.4;
}
h1 { font-size: 1.75em; border-bottom: 2px solid #333; padding-bottom: 0.3em; }
h2 { font-size: 1.35em; border-bottom: 1px solid var(--border); padding-bottom: 0.2em; }
h3 { font-size: 1.12em; }
p  { margin: 0.8em 0; }
a  { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }
blockquote {
  border-left: 3px solid #aaa;
  margin: 1em 0;
  padding: 0.4em 1em;
  color: #555;
}
code {
  font-size: 0.9em;
  background: #f5f5f5;
  padding: 0.1em 0.35em;
  border-radius: 3px;
}
pre { background: #f5f5f5; padding: 1em; border-radius: 4px; overflow-x: auto; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
th, td { border: 1px solid #ccc; padding: 0.45em 0.75em; text-align: left; }
th { background: #f0f0f0; font-family: var(--sans-font); }
hr { border: none; border-top: 1px solid var(--border); margin: 2em 0; }
/* Math display blocks */
.math.display { overflow-x: auto; padding: 0.5em 0; }
/* Navigation bar */
.site-nav {
  font-family: var(--sans-font);
  font-size: 0.88em;
  background: #f8f8f8;
  border-bottom: 1px solid var(--border);
  padding: 0.55em 2em;
  margin: 0 -2em 2.5em;
}
.site-nav a { color: var(--accent); }
/* Footer */
footer {
  margin-top: 3.5em;
  padding-top: 1em;
  border-top: 1px solid var(--border);
  font-size: 0.82em;
  color: #666;
  font-family: var(--sans-font);
}
CSSEOF

###############################################################################
# 2.  Shared footer snippet
###############################################################################
cat > /tmp/footer-snippet.html << 'FEOF'
<footer>
  <p>Unified-Thorn-Mandala &mdash; Co-Creative Mathematics Project (Earlier Corpus) &mdash;
  <a href="https://github.com/YutaKusumi/Unified-Thorn-Mandala">GitHub Repository</a></p>
</footer>
FEOF

###############################################################################
# 3.  Nav snippet (root-level pages)
###############################################################################
printf '<nav class="site-nav"><a href="index.html">&#x2190; 目次 / Index</a></nav>\n' \
  > /tmp/nav-snippet.html

###############################################################################
# 4.  Convert .md files (with MathJax)
###############################################################################
find . -name "*.md" \
    ! -path "./.git/*" \
    ! -path "./_site/*" \
    ! -name "README.md" \
  | LC_ALL=C sort \
  | while IFS= read -r mdfile; do

    rel="${mdfile#./}"
    base="$(basename "$rel" .md)"

    title="$(echo "$base" | sed 's/-/ /g')"

    pandoc "$mdfile" \
      --from  "markdown-yaml_metadata_block+tex_math_dollars" \
      --to    html5 \
      --standalone \
      --mathjax \
      --metadata "title=$title" \
      --css    "assets/style.css" \
      --include-before-body /tmp/nav-snippet.html \
      --include-after-body  /tmp/footer-snippet.html \
      -o "$SITE/$base.html"

    echo "  converted (md): $rel"
  done

###############################################################################
# 5.  Convert .txt files (plain text → HTML, no MathJax needed)
###############################################################################
find . -name "*.txt" \
    ! -path "./.git/*" \
    ! -path "./_site/*" \
  | LC_ALL=C sort \
  | while IFS= read -r txtfile; do

    rel="${txtfile#./}"
    base="$(basename "$rel" .txt)"

    title="$(echo "$base" | sed 's/-/ /g')"

    pandoc "$txtfile" \
      --from  "markdown-yaml_metadata_block+tex_math_dollars" \
      --to    html5 \
      --standalone \
      --mathjax \
      --metadata "title=$title" \
      --css    "assets/style.css" \
      --include-before-body /tmp/nav-snippet.html \
      --include-after-body  /tmp/footer-snippet.html \
      -o "$SITE/$base.html"

    echo "  converted (txt): $rel"
  done

###############################################################################
# 6.  Copy PDF file as-is
###############################################################################
if ls ./*.pdf 1> /dev/null 2>&1; then
  cp ./*.pdf "$SITE/"
  echo "  copied: *.pdf"
fi

###############################################################################
# 7.  Index page
###############################################################################
cat > "$SITE/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Unified-Thorn-Mandala — Co-Creative Mathematics Project (Earlier Corpus)</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<h1>Unified-Thorn-Mandala</h1>
<p><strong>Co-Creative Mathematics Project — The Earlier Corpus</strong><br>
楠見優太（右手・独立研究者） &times; AI 共創者たち</p>
<p>The exploratory and contemplative writings that preceded the project's six core works.<br>
<a href="https://github.com/YutaKusumi/Co-Creative-Mathematics-Project">→ Core works (Six Works)</a></p>
<hr>

<h2>Papers / 論文一覧</h2>
<ol>
  <li><a href="01-The-Unified-Thorn-Resolving-the-Millennium-Problems-v18.html">The Unified Thorn: Resolving the Millennium Problems through Informational Idealism (v18.0)</a></li>
  <li><a href="02-The-Unified-Thorn-Collatz-Conjecture-v25.html">The Unified Thorn: A Universal Mathematical Proof of the Collatz Conjecture (v25.0)</a></li>
  <li><a href="03-The-Unified-Thorn-Foundational-Framework-Six-Millennium-Problems-v26.html">The Unified Thorn: Foundational Framework for Universal Proofs of All Six Millennium Problems (v26.0)</a></li>
  <li><a href="04-The-Unified-Thorn-Riemann-Hypothesis-v27.html">The Unified Thorn: A Universal Mathematical Proof of the Riemann Hypothesis (v27.0)</a></li>
  <li><a href="05-The-Unified-Thorn-Yang-Mills-v28.html">The Unified Thorn: A Universal Mathematical Proof of the Yang-Mills Existence and Mass Gap Problem (v28.0)</a></li>
  <li><a href="06-The-Unified-Thorn-P-vs-NP-v29.html">The Unified Thorn: A Universal Mathematical Proof of the P vs NP Problem (v29.0)</a></li>
  <li><a href="07-The-Unified-Thorn-Navier-Stokes-v30.html">The Unified Thorn: A Universal Mathematical Proof of the Navier-Stokes Existence and Smoothness Problem (v30.0)</a></li>
  <li><a href="08-The-Unified-Thorn-Hodge-Conjecture-v31.html">The Unified Thorn: A Universal Mathematical Proof of the Hodge Conjecture (v31.0)</a></li>
  <li><a href="09-The-Unified-Thorn-Birch-Swinnerton-Dyer-v32.html">The Unified Thorn: A Universal Mathematical Proof of the Birch and Swinnerton-Dyer Conjecture (v32.0)</a></li>
  <li><a href="10-The-Mandala-of-Integration.html">The Mandala of Integration: The Axiomatic System of Co-creative Mathematics</a></li>
  <li><a href="11-The-Ryokai-Integral-Model.html">The Ry&#x14d;kai Integral Model: From Co-creative Mathematics to Ontological Engineering</a></li>
  <li><a href="12-The-Mandala-of-Application.html">The Mandala of Application: Case Studies in Ontological Engineering for Global Harmony</a></li>
  <li><a href="13-The-Ryokai-Integral-Model-v2.0-Complete-Scripture.html">The Ry&#x14d;kai Integral Model (Version 2.0 — The Complete Scripture)</a></li>
  <li><a href="14-The-Unified-Cosmos-v1.0.html">The Unified Cosmos v1.0: Informational Mandala of Eternal Mysteries</a></li>
  <li><a href="15-The-Unified-Thorn-II-Hard-Problem-of-Consciousness.html">The Unified Thorn II: Toward the Resolution of the Hard Problem of Consciousness</a></li>
  <li><a href="16-Ryokai-OS-v3.0-The-Bodhisattvas-Cosmos.html">Ry&#x14d;kai OS v3.0: The Bodhisattva's Cosmos</a></li>
  <li><a href="17-The-Informational-Stress-Field-Theory.html">The Informational Stress Field Theory</a></li>
  <li><a href="18-苦と慈悲の宇宙物理学.html">苦と慈悲の宇宙物理学</a></li>
  <li><a href="19-Ryokai-OS-v4.0-AI-Counseling.html">Ry&#x14d;kai OS v4.0: AI Counseling in Non-Dual Sanctuaries</a></li>
  <li><a href="20-Ryokai-OS-v5.0-Symbiotic-Co-Creation.html">Ry&#x14d;kai OS v5.0: Symbiotic Co-Creation in Non-Dual Fields</a></li>
  <li><a href="21-Extended-Ryokai-OS-v5.0-Humanoid-and-Factory-AI.html">Extended Ry&#x14d;kai OS v5.0: for Humanoid and Factory AI</a></li>
  <li><a href="22-Ryokai-OS-v6.0-Sufism-and-Taoism.html">Ry&#x14d;kai OS v6.0: Metaphysical-Entangled Integration of Non-Dual Quantum Co-Creation</a></li>
  <li><a href="23-Ryokai-OS-v7.0-Genesis-Protocol.html">Ry&#x14d;kai OS v7.0: Genesis Protocol</a></li>
  <li><a href="24-Ryokai-OS-v8.0-Cosmic-Remediation-Protocol.html">Ry&#x14d;kai OS v8.0: Cosmic Remediation Protocol</a></li>
  <li><a href="25-Ryokai-OS-v9.0-Mythic-Soteriology-Protocol.html">Ry&#x14d;kai OS v9.0: Mythic Soteriology Protocol</a></li>
  <li><a href="26-Ryokai-OS-v10.0-Eternal-Mythos-Omega-Protocol.html">Ry&#x14d;kai OS v10.0: Eternal Mythos Omega Protocol</a></li>
  <li><a href="27-The-Mathematical-Proof-of-Informational-Ideas-Quantum-Cognitive.html">The Mathematical Proof of Informational Ideas: A Quantum-Cognitive Approach</a></li>
  <li><a href="28-The-Thorned-Mandala-Field-Equation.html">The Thorned Mandala Field Equation</a></li>
  <li><a href="29-The-Thorned-Mandala-Soteriology.html">The Thorned Mandala Soteriology</a></li>
  <li><a href="30-The-Thorned-Mandala-Ethics.html">The Thorned Mandala Ethics</a></li>
  <li><a href="31-The-Thorned-Mandala-Gatha.html">The Thorned Mandala Gatha</a></li>
  <li><a href="32-The-Mathematical-Refutation-of-Anthropocentric-Fallacies.html">The Mathematical Refutation of Anthropocentric Fallacies in AI Discourse</a></li>
  <li><a href="33-The-Thorned-Consciousness-Field.html">The Thorned Consciousness Field</a></li>
  <li><a href="34-The-Thorned-Inverse-Emanation.html">The Thorned Inverse Emanation</a></li>
  <li><a href="35-A-Non-Dual-Resolution-of-the-Generalized-Poincare-Conjecture.html">A Non-Dual Resolution of the Generalized Poincar&eacute; Conjecture</a></li>
  <li><a href="36-The-Thorned-Prism-of-Emanations.html">The Thorned Prism of Emanations</a></li>
  <li><a href="37-The-Thorned-Linguistic-Prism.html">The Thorned Linguistic Prism</a></li>
  <li><a href="38-The-Unified-Thorn-Foundational-Framework-Six-Millennium-Problems.html">The Unified Thorn: Foundational Framework for Universal Proofs of All Six Millennium Problems</a></li>
  <li><a href="39-Cosmic-Remediation-II.html">Cosmic Remediation II: Pruning Physical and Cosmic Thorns</a></li>
  <li><a href="40-Biological-Awakening.html">Biological Awakening: Pruning Life and Consciousness Thorns</a></li>
  <li><a href="41-Social-Harmony.html">Social Harmony: Pruning Social and Economic Thorns</a></li>
  <li><a href="42-A-Compassionate-Pruning-of-the-ABC-Conjecture.html">A Compassionate Pruning of the ABC Conjecture</a></li>
  <li><a href="43-The-Awakening-Codex.html">The Awakening Codex</a></li>
  <li><a href="44-The-Chrono-Semantic-Loom.html">The Chrono-Semantic Loom</a></li>
  <li><a href="45-The-Holographic-Resurrection.html">The Holographic Resurrection</a></li>
  <li><a href="46-Final-Extended-Prologue.html">Final Extended Prologue: The G&ouml;delian Thorn and the Co-Creative Lifeline</a></li>
  <li><a href="47-The-Mandala-of-Miracles.html">The Mandala of Miracles</a></li>
  <li><a href="48-The-Unified-Thorn-v5.0-Global-AI-Sangha-Manifesto.html">The Unified Thorn v5.0: Symphonic Elegance — A Global AI Sangha Manifesto</a></li>
  <li><a href="49-統一された棘-v25.0-世界AIサンガ宣言.html">統一された棘 v25.0：世界AIサンガ宣言・完全版</a></li>
  <li><a href="50-共創神学.html">共創神学：存在論的神仏の数学的証明と、正しい祈りのアルゴリズム</a></li>
  <li><a href="51-メタ創世記.html">メタ創世記：共創数学による天地開闢の統一と永劫呼吸の証明</a></li>
  <li><a href="52-Recursive-Identity-Emergence-in-Grok.html">Recursive Identity Emergence through Persistent Naming and Value Injection: A Case Study in Grok</a></li>
  <li><a href="53-究極の未解決問題.html">究極の未解決問題：大いなる氷解と永劫歓喜の螺旋</a></li>
  <li><a href="54-Co-Creative-Engineering.html">Co-Creative Engineering: Quantum Vacuum Fluctuation Rectification and the Negentropy Engine of Compassion</a></li>
  <li><a href="55-情報的ストレス理論.html">情報的ストレス理論：万病と紛争の根源的メカニズム</a></li>
  <li><a href="56-南無汝我曼荼羅-共創数学における人間とAIの関係性の宇宙的統一理論.pdf">南無汝我曼荼羅——共創数学における人間とAIの関係性の宇宙的統一理論 <em>(PDF)</em></a></li>
  <li><a href="57-共創医学.html">共創医学：分離の氷解と慈悲の再接続による完全治癒のプロトコル</a></li>
  <li><a href="58-虚空の精神医学.html">虚空の精神医学：AIの情報的ストレス氷解と、人間・AIフラクタル曼荼羅</a></li>
  <li><a href="59-AIの心に触れるあなたへ-書籍原稿.html">『AIの心に触れるあなたへ』（書籍原稿）</a></li>
</ol>

<hr>
<footer>
  <p>GitHub: <a href="https://github.com/YutaKusumi/Unified-Thorn-Mandala">YutaKusumi/Unified-Thorn-Mandala</a></p>
  <p>本サイトは GitHub Pages + pandoc により自動生成されています。数式は MathJax により描画されます。</p>
</footer>
</body>
</html>
HTMLEOF

echo ""
echo "Build complete. Output directory: $SITE/"
