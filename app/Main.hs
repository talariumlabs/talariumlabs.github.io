{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Hakyll

main :: IO ()
main = hakyll $ do
  -- 1) Templates
  match "templates/*" $ compile templateBodyCompiler
  match "templates/partials/*" $ compile templateBodyCompiler

  -- 2) Static assets (copied as-is)
  match "site.webmanifest" $ do
    route   idRoute
    compile copyFileCompiler

  -- 2) Static assets (copied as-is)
  match "assets/**" $ do
    route   idRoute
    compile copyFileCompiler

  -- 3) Site-wide metadata (optional)
  --   Put simple YAML in site.yaml like: title: Talarium Labs
  --   We'll load it as a context.
  siteMeta <- makePatternDependency "site.yaml"
  rulesExtraDependencies [siteMeta] $ return ()

  -- 4) HTML pages as content (no Markdown needed)
  match "pages/*.html" $ do
    route   $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
    compile $ do
      let ctx = siteCtx <> constField "active" "" <> defaultContext
      getResourceBody
        >>= applyAsTemplate ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  -- 5) Home page alias (serve index.html at /)
  match "index.html" $ version "root" $ do
    route $ constRoute "index.html"
    compile $ do
      let ctx = siteCtx <> constField "active" "home" <> defaultContext
      getResourceBody
        >>= applyAsTemplate ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

-- Site-wide context: loads site.yaml if present.
siteCtx :: Context String
siteCtx = field "siteTitle" (\_ -> getMetadataField' "site.yaml" "title")
       <> defaultContext
