{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module X.Language.Haskell.TH (
    qmaybe
  , qeither
  , qparse
  , dataExp
  , textExp
  ) where


import           Control.Applicative (pure)

import           Data.Data (Data)
import           Data.Either
import           Data.Function (const, ($), (.))
import           Data.Generics (extQ)
import           Data.Maybe
import           Data.Monoid ((<>))
import           Data.String ( String )
import qualified Data.Text as T

import           Language.Haskell.TH
import           Language.Haskell.TH.Quote

import qualified Prelude as P (error)

import           Text.Show (Show, show)


qmaybe :: (Data a) => (T.Text -> Maybe a) -> QuasiQuoter
qmaybe parse = qparse $ \s ->
  case parse (T.pack s) of
    Nothing ->
      P.error $ "Failed to parse quasi quoter: " <> s
    Just m ->
      dataExp m

qeither :: (Data a, Show b) => (T.Text -> Either b a) -> QuasiQuoter
qeither parse = qparse $ \s ->
  case parse (T.pack s) of
    Left b ->
      P.error $ "Failed to parse quasi quoter: " <> show b
    Right a ->
      dataExp a

dataExp :: Data a => a -> Q Exp
dataExp a = dataToExpQ (const Nothing `extQ` textExp) a

textExp :: T.Text -> Maybe ExpQ
textExp = pure . appE (varE 'T.pack) . litE . StringL . T.unpack

qparse :: (String -> Q Exp) -> QuasiQuoter
qparse parse = QuasiQuoter {
    quoteExp    = parse
  , quotePat    = P.error "not able to qq pats"
  , quoteType   = P.error "not able to qq types"
  , quoteDec    = P.error "not able to qq decs"
  }
