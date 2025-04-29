"""
Script to automate git add, git commit and git push
"""
import os
import argparse


def arguments() -> dict:
    """
    Function to get command line args

    Parameters
    ----------
    None 

    Returns
    -------
    dict: dictionary object
        dict object of cmd arguments 
    """
    base_parser = argparse.ArgumentParser(
        prog="git script",
    )
    base_parser.add_argument(
        "-m",
        "--commit_message",
        help="Commit message for git.",
        dest="commit_message",
        required=True,
    )
    return vars(base_parser.parse_args())


def main() -> None:
    """
    Main function that
    runs git add, git commit 
    and git push. Needs to be run 
    in git directory

    Parameters
    ----------
    None

    Returns
    -------
    None
    """
    args = arguments()
    os.system(f"git add {os.getcwd()}")
    os.system(f"""git commit -m "{args["commit_message"]}" """)
    os.system("git push")


if __name__ == "__main__":
    main()
