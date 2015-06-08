
-- base
import System.Process (system)
import System.Directory
import System.FilePath (takeExtension,dropExtension)

-- Cabal
import Distribution.Package (pkgVersion)
import Distribution.PackageDescription
import Distribution.PackageDescription.Parse (parsePackageDescription,ParseResult (..))
import Data.Version (showVersion)

main :: IO ()
main = do
  xs <- getDirectoryContents "."
  let ys = filter ((==".cabal") . takeExtension) xs
  if length ys /= 1
     then putStrLn "Zero or multiple cabal files. Can't continue."
     else tagthis $ head ys

tagthis :: FilePath -> IO ()
tagthis fp = do
  let n = dropExtension fp
  t <- readFile fp
  case parsePackageDescription t of
    ParseFailed _ -> putStrLn "Corrupted cabal file."
    ParseOk _ c -> do
      let v = showVersion $ pkgVersion $ package $ packageDescription c
      system $ "git tag -a v" ++ v ++ " -m 'Version " ++ v ++ " of package " ++ n ++ "'."
      system $ "git show v" ++ v
      system "git push --tags"
      putStrLn "tagthis ended."
