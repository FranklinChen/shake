
import Neil
import System.Directory

main = do
    -- grab ninja
    cmd "git clone https://github.com/martine/ninja"
    cmd "cd ninja && ./bootstrap.py"
    cmd "mkdir bin"
    cmd "cp ninja/ninja nin"
    setCurrentDirectory "ninja"

    retry 3 $ do

        -- time Ninja
        cmd "../nin -t clean"
        (ninjaFull, _) <- duration $ cmd "../nin -j3 -d stats"
        (ninjaZero, _) <- duration $ cmd "../nin -j3 -d stats"

        -- time Shake
        cmd "../nin -t clean"
        (shakeFull, _) <- duration $ cmd "shake -j3 --quiet --timings"
        (shakeZero, _) <- duration $ cmd "shake -j3 --quiet --timings"

        -- Diagnostics
        cmd "ls -l .shake* build/.ninja*"
        cmd "shake -VVVV"

        let ms x = show $ ceiling $ x * 1000
        putStrLn $ "Ninja was " ++ ms ninjaFull ++ " then " ++ ms ninjaZero
        putStrLn $ "Shake was " ++ ms shakeFull ++ " then " ++ ms shakeZero

        when (ninjaFull < shakeFull) $
            error "ERROR: Ninja build was faster than Shake"

        when (ninjaZero + 0.1 < shakeZero) $
            error "ERROR: Ninja zero build was more than 0.1s faster than Shake"
