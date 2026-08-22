# What's for Dinner?

A small Rails app that helps you find the recipes you can most realistically
cook **right now**, based on the ingredients you already have at home.

Built as a take-home assignment for Pennylane.

**Live app:** https://pennylane-recipe-finder-still-current-4837.fly.dev
_(update this if recipe_browser is deployed under a different Fly.io app)_

## User stories

1. **As a home cook with a half-full fridge**, I want to tell the app which
   ingredients I have, so that it can suggest recipes I can actually make
   instead of ones that need a trip to the store.
2. **As someone deciding what to cook**, I want recipes ranked by how much of
   each one I already have, so the recipe I'm *closest* to being able to
   cook (not just any recipe containing one of my ingredients) rises to the
   top.
3. **As a user who forgot what's in a recipe**, I want to see, ingredient by
   ingredient, what I have and what I'm missing, so I know exactly what to
   pick up before I start cooking.

## How it works

1. Search for ingredients you have and add them to your **pantry** (kept in
   your session — no account needed). You need at least 3 ingredients in
   your pantry before you can browse recipes — fewer than that isn't enough
   to produce a meaningful ranking.
2. Hit **Find recipes**. Recipes are ranked by the *share* of their
   ingredients that are in your pantry (a recipe you can make with 3 out of
   4 ingredients you have ranks above one where you only have 3 out of 10).
3. Open a recipe to see the full ingredient list, with a checkmark next to
   what you already have.

## How it works

Search for ingredients, add the ones you have to your pantry (this lives
in your session, no login needed), then hit "Find recipes." You need at
least 3 ingredients in your pantry before results show up — fewer than
that and the ranking doesn't really mean anything yet. Recipes get sorted
by what share of their ingredients you already have. Click into one and
you'll see the full ingredient list with checkmarks for what you have and
plain dashes for what you're missing.

## The data

Three tables: `recipes`, `ingredients`, and `recipe_ingredients` joining
them — pretty standard many-to-many. `ingredients` holds a normalized name
like "chicken breast," and `recipe_ingredients` keeps the original line
from the recipe ("2 lbs boneless skinless chicken breast, cubed") plus a
link to that canonical ingredient, so the recipe page can still show the
line the way the recipe actually wrote it.

Seed data is the allrecipes.com dataset from the assignment (~10k recipes),
committed straight into the repo as `db/seed_data/recipes-en.json.gz` so
nobody has to go re-download it from S3 to get the app running.

## Why normalize ingredients at all

The raw dataset has about 96k ingredient lines but only ~10k of them are
actually distinct — most of the duplication is just quantity noise ("1 cup
flour" vs "2 cups flour" vs "3 1/2 cups flour"). `IngredientNormalizer`
strips that off with a handful of regexes and gets it down to about 10.2k
canonical names, which was a big enough reduction that a real join made
more sense than just stuffing raw ingredient strings onto the recipe row.

It's not a real parser though — doesn't merge "egg"/"eggs", doesn't know
synonyms. I left that fuzziness for search time instead of trying to get
normalization perfect, since a prototype doesn't need a flawless ingredient
dictionary to answer "what can I cook."

## How the ranking works

`Recipe.ranked_by_pantry` computes matched ingredients over total
ingredients per recipe and sorts by that ratio. A recipe only shows up at
all if you match at least 2 of its ingredients — the cutoff is on how many
actually matched, not how big the recipe is, so a 10-ingredient recipe
where you only have 1 thing gets excluded just like a 2-ingredient recipe
would. That's on purpose: real overlap decides relevance, not recipe size.

That's a separate number from the pantry-size gate (3) mentioned above —
one is "is your pantry big enough to rank against," the other is "does
this specific recipe overlap with you enough to bother showing." Both
numbers came from just trying values against the real dataset until
results looked sane, not from any formula.

## Other decisions worth mentioning

**One controller for the pantry, not two.** Originally split "view/search
the pantry" and "add or remove an item" into separate controllers, but the
pantry isn't really its own resource — it's just an array of ids in the
session, no attributes of its own. Merged it into one
`PantryItemsController` (index/create/destroy) once that became obvious.

**Search uses pg_trgm.** `Ingredient.search` does fuzzy matching via
Postgres trigram similarity, so typing "chick" finds "chicken breast" and
typing "eggs" still finds "egg" even though normalization never merged
those two.

**No accounts.** The pantry is session-only. Auth wasn't part of the
problem and the assignment specifically says not to add things that don't
answer it directly.

**No cooking steps.** The dataset doesn't include instructions or a source
URL, just title/ingredients/category/rating/etc. The recipe page says so
instead of pretending — this is about deciding what to cook, not being a
full cookbook.

## Stack

Rails 8, server-rendered views with a bit of Turbo, no JS framework.
Postgres with pg_trgm enabled. Minitest for tests.

## Running it locally

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
bin/rails test ## Tests


Used Claude Code (Anthropic) throughout, mainly for:

- Exploring the dataset and drafting the seed script that loads and
  normalizes the ~10k recipes.
- Drafting the ranking SQL in `Recipe.ranked_by_pantry` and the regex in
  `IngredientNormalizer`.
- Writing the test suite — fixtures, unit tests, the integration tests
  walking the pantry → recipes flow.
- Cleaning up code style and writing this README.
