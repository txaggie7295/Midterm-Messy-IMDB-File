# IMDB Top 100 — Data Analysis Report

**Midterm Project — Texas State University Data Analytics Bootcamp**
**Author:** Jeffrey Symons
**Tools:** Microsoft Excel, SQLite
**Repository:** [github.com/txaggie7295/Midterm-Messy-IMDB-File](https://github.com/txaggie7295/Midterm-Messy-IMDB-File)

---

## 1. Dataset Introduction

### Source
The analysis uses a dataset of the top 100 IMDB-rated films, provided as a deliberately messy CSV file (`messy_IMDB_dataset.csv`) for the midterm data-cleaning exercise. The cleaned dataset is preserved in `IMDB_Cleaned.xlsx` and reproduced in a single SQLite table (`imdb_main`) for the SQL analysis. The full cleaning methodology is documented in the Data Dictionary tab of the cleaned workbook.

### Size and Structure
- **Tables:** 1 (`imdb_main`)
- **Records:** 100 films
- **Source fields:** 12, expanded to 14 after splitting multi-value Genre and Director columns
- **Temporal range:** 1936 (*Modern Times*) through 2020 (*1917*)
- **Score range:** 7.4 to 9.3

### Subject Matter
The dataset contains top-rated theatrical films with attributes spanning three categories: film identity (IMDB ID, original title), production attributes (release year, country of origin, director, runtime, content rating), and outcome metrics (audience score, vote count, box office income). Income is U.S.-dollar theatrical box office, unadjusted for inflation.

---

## 2. Analysis Objectives

### Primary Business Question
**For a studio deciding where to deploy production capital among critically-recognized films, which production attributes drive disproportionate commercial returns?**

The question is framed around capital allocation because production attributes such as genre, content rating, and directorial choice are *levers* a studio actually controls at green-light, whereas outcome metrics such as audience score are not directly chosen. The analysis seeks to identify which controllable inputs predict commercial outperformance and which do not.

### Patterns Investigated
1. Whether revenue concentrates in specific genres disproportionate to their frequency
2. Whether MPAA content rating materially affects commercial ceiling
3. Whether audience score predicts commercial performance, or whether quality and commercial success are independent dimensions among elite films

### Hypotheses Tested

| Hypothesis | Statement |
|---|---|
| **H1** | Revenue is unevenly distributed across genres. A small number of genres generate disproportionate per-film revenue. |
| **H2** | Content rating affects commercial ceiling. Broad-audience ratings (G, PG-13) produce higher per-film revenue than restricted ratings (R). |
| **H3** | Above a quality threshold, audience score does not predict income. Critical acclaim and commercial success are largely independent dimensions among elite films. |

---

## 3. Analytical Approach and Findings

### Methods Used

**Excel** was used for data cleaning, pivot table aggregation, and the density metric. Cleaning techniques included `Get Data → From Text/CSV` import with explicit semicolon delimiter and UTF-8 encoding, `NUMBERVALUE` and `DATEVALUE` for type conversion, `Text to Columns` for multi-value field decomposition, and direct lookup against IMDB.com to recover missing values rather than discard records. All transformations are documented in the Data Dictionary tab of `IMDB_Cleaned.xlsx`.

**SQLite** was used for the score-and-income analysis. Two queries were constructed using common table expressions (CTEs) and window functions to segment films by score tier and to rank films simultaneously on critical and commercial dimensions.

### The Density Metric

A custom analytical metric was developed and applied consistently across all category-level analyses:

> **Density = (% of Total Income) ÷ (% of Total Movies)**

A density of 1.0 indicates a category contributes its proportional share of revenue. Values above 1.0 indicate overperformers; values below 1.0 indicate underperformers. The metric resolves the limitation of raw counts and raw revenue when used in isolation — Drama appears in 25% of films but contributes only 11% of income, while Action appears in 19% of films but contributes 49%. Density makes these comparable on a single scale.

All densities in this report are calculated against the full 100-movie dataset baseline.

---

### Finding 1: Revenue Concentrates in Two Genres

Excel pivot analysis of the cleaned dataset produced the following genre density rankings:

| Genre | Films | % of Movies | % of Income | Density |
|---|---:|---:|---:|---:|
| Action | 19 | 19% | 48.8% | **2.57** |
| Animation | 9 | 9% | 15.6% | **1.73** |
| Adventure | 7 | 7% | 5.1% | 0.73 |
| Crime | 16 | 16% | 11.1% | 0.69 |
| Biography | 6 | 6% | 3.9% | 0.66 |
| Drama | 25 | 25% | 11.3% | **0.45** |
| Comedy | 10 | 10% | 3.3% | 0.33 |
| Horror | 2 | 2% | 0.5% | 0.23 |
| Mystery | 3 | 3% | 0.3% | 0.09 |
| Western | 3 | 3% | 0.1% | 0.04 |

**Insight:** Action carries the box office. Animation is the only other meaningful overperformer. Drama — the most common genre in elite films — is one of the least commercially efficient on a per-title basis. The most-frequent genre is not the most-profitable genre. **H1 is supported:** revenue is heavily concentrated in two of ten genres.

---

### Finding 2: Content Rating Materially Affects Commercial Ceiling

| Rating | Films | % of Movies | % of Income | Density |
|---|---:|---:|---:|---:|
| PG-13 | 16 | 16% | 42.6% | **2.66** |
| G | 8 | 8% | 10.1% | **1.27** |
| PG | 17 | 17% | 14.7% | 0.87 |
| R | 53 | 53% | 32.4% | 0.61 |
| Approved | 3 | 3% | 0.09% | 0.03 |
| Not Rated | 3 | 3% | 0.003% | 0.001 |

**Insight:** R-rated films dominate by volume (53%) but underperform commercially. PG-13 is the inverse — fewer titles, far higher per-film revenue. The rating decision is therefore a material commercial choice, not merely a creative one. **H2 is supported:** broader-audience ratings produce meaningfully higher per-film revenue.

---

### Finding 3: Rating and Genre Effects Compound

Cross-tabulating the two highest-density ratings (G and PG-13) against their constituent genres revealed concentration patterns that neither dimension produces in isolation:

| Combination | Films | Density |
|---|---:|---:|
| **PG-13 + Action** | 8 | **4.51** |
| G + Animation | 4 | **2.47** |
| PG-13 + Adventure | 1 | 2.33 |
| PG-13 + Drama | 3 | 0.90 |
| PG-13 + Animation | 1 | 0.57 |
| PG-13 + Comedy | 2 | 0.49 |
| G + Adventure | 1 | 0.23 |
| G + Comedy | 3 | 0.004 |
| PG-13 + Western | 1 | 0.0004 |

**Insight:** PG-13 + Action — the modern blockbuster formula — generates 4.5x its proportional share of revenue, meaningfully more than either factor alone (PG-13 at 2.66, Action at 2.57). G + Animation, the Pixar/Disney lane, punches at 2.5x. Outside these two combinations, density falls off sharply. Revenue concentration in this dataset is far narrower than the count distribution suggests.

---

### Finding 4: A Quality Threshold Exists, but Score Above It Does Not Predict Income

**Query 1 — Score Tier Density**

```sql
WITH tiered AS (
    SELECT 
        CASE 
            WHEN score >= 9.0 THEN 'A: Masterpiece (9.0+)'
            WHEN score >= 8.5 THEN 'B: Acclaimed (8.5-8.9)'
            WHEN score >= 8.0 THEN 'C: Very Good (8.0-8.4)'
            ELSE 'D: Good (7.4-7.9)'
        END AS score_tier,
        income
    FROM imdb_main
)
SELECT 
    score_tier,
    COUNT(*) AS films,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM imdb_main), 1) AS pct_of_films,
    ROUND(AVG(income), 0) AS avg_income,
    ROUND(100.0 * SUM(income) / (SELECT SUM(income) FROM imdb_main), 1) AS pct_of_income,
    ROUND(
        (100.0 * SUM(income) / (SELECT SUM(income) FROM imdb_main)) /
        (100.0 * COUNT(*) / (SELECT COUNT(*) FROM imdb_main)),
        2
    ) AS density
FROM tiered
GROUP BY score_tier
ORDER BY score_tier;
```

**Results:**

| Tier | Films | % of Films | Avg Income | % of Income | Density |
|---|---:|---:|---:|---:|---:|
| A: Masterpiece (9.0+) | 4 | 4% | $422,106,803 | 5.6% | **1.41** |
| B: Acclaimed (8.5–8.9) | 32 | 32% | $356,020,608 | 38.1% | 1.19 |
| C: Very Good (8.0–8.4) | 36 | 36% | $361,683,637 | 43.5% | 1.21 |
| D: Good (7.4–7.9) | 28 | 28% | $136,101,840 | 12.7% | **0.45** |

**Insight:** The relationship between score and income is a **threshold, not a slope**. Films scoring below 8.0 (tier D) earn only 0.45x their proportional revenue share — a sharp underperformance. Films scoring above 8.0 (tiers A, B, C) all overperform, but at near-identical rates (1.19 to 1.41). A film scoring 8.2 generates the same revenue share as a film scoring 8.8. Tier A's slight edge is driven primarily by *The Dark Knight* ($1.0B) — strip that single film and tier A averages fall below tiers B and C.

The conclusion: clearing 8.0 matters enormously; pushing well past it does not.

---

### Finding 5: Critical Winners and Commercial Winners Are Largely Different Films

**Query 2 — Top 10 by Score vs. Top 10 by Income**

```sql
WITH ranked AS (
    SELECT 
        original_title,
        score,
        income,
        RANK() OVER (ORDER BY income DESC) AS income_rank,
        RANK() OVER (ORDER BY score DESC) AS score_rank
    FROM imdb_main
)
SELECT 
    original_title,
    score,
    income,
    income_rank,
    score_rank,
    CASE 
        WHEN income_rank <= 10 AND score_rank <= 10 THEN 'Both lists'
        WHEN income_rank <= 10 THEN 'Top earner only'
        ELSE 'Top scorer only'
    END AS appears_in
FROM ranked
WHERE income_rank <= 10 OR score_rank <= 10
ORDER BY appears_in, income_rank, score_rank;
```

**Results (abbreviated):**

| Film | Score | Income | Income Rank | Score Rank | Appears In |
|---|---:|---:|---:|---:|---|
| LOTR: Return of the King | 8.9 | $1.14B | 3 | 5 | **Both lists** |
| The Dark Knight | 9.0 | $1.01B | 7 | 3 | **Both lists** |
| LOTR: Fellowship of the Ring | 8.8 | $888M | 10 | 9 | **Both lists** |
| Avengers: Endgame | 8.2 | $2.80B | 1 | 52 | Top earner only |
| Avengers: Infinity War | 8.2 | $2.05B | 2 | 52 | Top earner only |
| The Dark Knight Rises | 8.3 | $1.08B | 4 | 44 | Top earner only |
| Joker | 8.4 | $1.07B | 5 | 37 | Top earner only |
| Toy Story 3 | 7.8 | $1.07B | 6 | 78 | Top earner only |
| The Shawshank Redemption | 9.3 | $28.8M | 71 | 1 | Top scorer only |
| The Godfather | 9.2 | $246M | 40 | 2 | Top scorer only |
| The Godfather: Part II | 9.0 | $408M | 25 | 3 | Top scorer only |
| Schindler's List | 8.9 | $322M | 34 | 5 | Top scorer only |
| Pulp Fiction | 8.9 | $223M | 43 | 5 | Top scorer only |
| Forrest Gump | 8.8 | $678M | 15 | 9 | Top scorer only |
| Inception | 8.8 | $870M | 11 | 9 | Top scorer only |

**Insight:** Of 20 films comprising the combined top 10 by income and top 10 by score, only 3 appear on both lists — *LOTR: Return of the King*, *The Dark Knight*, and *LOTR: Fellowship of the Ring*. **85% of films at the top of one list are not at the top of the other.** The divergence is dramatic at the extremes: *The Shawshank Redemption*, the dataset's highest-scored film, ranks 71st in income. *Avengers: Endgame*, the dataset's highest earner, ranks 52nd in score.

A pattern in the three "both lists" films is worth noting: each is an established franchise IP elevated by an auteur director (Peter Jackson directing two LOTR entries, Christopher Nolan directing *The Dark Knight*). This combination — pre-built audience plus distinctive directorial voice — appears to be the formula for simultaneous critical and commercial outperformance.

**H3 is supported:** above the 8.0 quality threshold, audience score and box office income are largely independent. Critical winners and commercial winners are different populations of films.

---

### Data Quality Note

The income field for *12 Angry Men* (1957) records as $576, almost certainly a source-data artifact for a pre-1970 limited-release film. This anomaly does not affect the directional findings — the film remains a top scorer in the dataset regardless of its income value — but is noted here in the interest of analytical transparency.

---

## 4. Business Recommendations

The analysis supports five recommendations a studio could act on at the green-light stage.

### Recommendation 1: Concentrate Production Capital in PG-13 Action and G Animation

These two combinations produced densities of 4.51 and 2.47 respectively — meaningfully higher than any other category. Among elite films, no other rating + genre combination approaches their commercial efficiency. A studio optimizing for revenue density should allocate disproportionate capital to these two lanes.

### Recommendation 2: Treat R-Rating as a Creative Choice, Not a Commercial One

R-rated films comprise 53% of the dataset but generate only 32% of revenue (density 0.61). When a project requires an R rating for creative reasons, that decision should be made with explicit acknowledgment of its commercial implications. R-rated films can succeed critically and commercially — but on average they yield less per dollar invested than a comparable PG-13 release.

### Recommendation 3: Set a Quality Floor at Score 8.0, Not a Quality Ceiling

Films scoring below 8.0 earn 38% as much on average as films above it. Clearing that threshold is a clear commercial requirement. However, pushing score from 8.0 to 8.5 or 8.5 to 9.0 produces no measurable revenue lift — tiers B and C are statistically indistinguishable. Quality assurance investment should target the floor, not the ceiling.

### Recommendation 4: Do Not Over-Invest in Score-Chasing Above the Floor

Reshoots, additional editing passes, prestige campaign positioning, and other expenditures aimed at moving a film from 8.0 to 8.5 do not pay back in box office. The data strongly suggests this incremental spend is misallocated. Those dollars are better directed toward category positioning (PG-13 Action, G Animation) or franchise development.

### Recommendation 5: For Simultaneous Critical and Commercial Returns, Pair Franchise IP with Auteur Direction

Only three films in the dataset achieved both top-10 commercial and top-10 critical performance, and all three followed the same pattern: established franchise material handed to a director with a distinctive creative voice (Peter Jackson's LOTR, Christopher Nolan's Batman). When a studio's strategic goal requires both kinds of return, this pairing represents the most identifiable formula in the data.

---

## Limitations

This analysis carries several limitations that constrain the generalizability of its findings.

**Selection bias** is the most important caveat. The dataset is approximately the IMDB top 100 — every film in it is critically acclaimed (scores 7.4 to 9.3). The findings describe revenue patterns *among already-successful films*, not films in general. The conclusion is not "PG-13 Action films make money" — many fail. The conclusion is "*among films that achieve elite critical reception*, PG-13 Action concentrates the most revenue." A studio applying these findings should treat the density rankings as guidance for which categories have the highest ceiling conditional on quality, not as a prediction that any individual investment will succeed.

**Other limitations:**
- Income is unadjusted for inflation, understating older films relative to newer ones.
- Theatrical revenue only; streaming, home video, and licensing are excluded.
- Multi-genre films are counted in each of their assigned genres, inflating common secondary genres such as Drama.
- The Genre × Rating crosstab focuses on G and PG-13; R-rated combinations were not decomposed in this analysis.
- The 100-film sample size is small. Findings are directional; statistical significance is not formally tested.

---

## Conclusion

The analysis identifies a coherent set of decision-relevant patterns. Genre concentrates revenue narrowly. Content rating materially affects commercial ceiling. The two effects compound, producing a small number of high-density combinations. Audience score functions as a quality floor rather than a continuous predictor — once cleared, other production decisions drive commercial outcomes. The three films that achieve both critical and commercial elite status share an identifiable formula: established franchise IP directed by a singular creative voice.

For a capital-allocation decision-maker, the practical implication is clear: optimize the levers you control at green-light (rating, genre, IP, director), set a quality floor rather than chasing the ceiling, and recognize that critical and commercial success are largely separate dimensions to be pursued with distinct strategies — or, in rare cases, simultaneously through the franchise-plus-auteur pairing.

---

*Author: Jeffrey Symons · [LinkedIn](https://linkedin.com/in/jeffsymons) · [GitHub](https://github.com/txaggie7295)*
