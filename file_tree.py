import os

def generate_tree(root: str, prefix: str='') -> list:
    """
    Function to get a list of content
    from repo and put it in a tree like format

    Parameters
    -----------
    root: str
        str of root directory
    prefix: str
        str of prefix
    
    Returns
    -------
    tree: list
        list of content in directory
    """
    exclude = ["README.md", "file_tree.py", "LICENSE"]
    tree = []
    files = sorted(os.listdir(root))
    files = [fil for fil in files if not fil.startswith('.') and fil not in exclude]
    pointers = ['├── '] * (len(files) - 1) + ['└── ']
    for pointer, filename in zip(pointers, files):
        path = os.path.join(root, filename)
        tree.append(f"{prefix}{pointer}{filename}")
        if os.path.isdir(path):
            extension = '│   ' if pointer != '└── ' else '    '
            tree.extend(generate_tree(path, prefix + extension))
    return tree

def update_readme(tree_lines: list, readme_path: str='README.md') -> None:
    """
    Function to update README

    Parameters
    ----------
    tree_lines: list
        list of content  
    readme_path: str
        path to readme file
    
    Returns
    -------
    None
    """
    with open(readme_path, 'r') as fil:
        lines = fil.readlines()

    content_start = None
    for line_value, line in enumerate(lines):
        if line.strip() == "## Content":
            content_start = line_value
            break

    if content_start is None:
        raise ValueError("No '## Content' header found in README.md")

    # Find where the content ends (next header or end of file)
    for file_line in range(content_start + 1, len(lines)):
        if lines[file_line].startswith('#'):
            content_end = file_line
            break
    else:
        content_end = len(lines)

    new_content = ["\n", "```\n"] + [line + "\n" for line in tree_lines] + ["```\n"]
    lines = lines[:content_start + 1] + new_content + lines[content_end:]

    with open(readme_path, 'w') as fil:
        fil.writelines(lines)

if __name__ == '__main__':
    tree = generate_tree(os.path.join(os.path.dirname(__file__)))
    update_readme(tree, os.path.join(os.path.dirname(__file__), 'README.md'))